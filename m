Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id EB71D6B025F
	for <linux-mm@kvack.org>; Sun, 19 Jun 2016 17:53:01 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id c1so19813876lbw.0
        for <linux-mm@kvack.org>; Sun, 19 Jun 2016 14:53:01 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id 8si12007452wmu.80.2016.06.19.14.53.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 Jun 2016 14:53:00 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id c82so6976081wme.3
        for <linux-mm@kvack.org>; Sun, 19 Jun 2016 14:53:00 -0700 (PDT)
Date: Sun, 19 Jun 2016 23:52:58 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] vhost, mm: make sure that oom_reaper doesn't reap
 memory read by vhost
Message-ID: <20160619215258.GA2110@dhcp22.suse.cz>
References: <1466154017-2222-1-git-send-email-mhocko@kernel.org>
 <20160618025904-mutt-send-email-mst@redhat.com>
 <20160619213543.GA32752@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160619213543.GA32752@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Vladimir Davydov <vdavydov@parallels.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, virtualization@lists.linux-foundation.org, LKML <linux-kernel@vger.kernel.org>

On Sun 19-06-16 23:35:43, Michal Hocko wrote:
> On Sat 18-06-16 03:09:02, Michael S. Tsirkin wrote:
> > On Fri, Jun 17, 2016 at 11:00:17AM +0200, Michal Hocko wrote:
[...]
> > >  /*
> > > + * A safe variant of __get_user for for use_mm() users to have a
> > > + * gurantee that the address space wasn't reaped in the background
> > > + */
> > > +#define __get_user_mm(mm, x, ptr)				\
> > > +({								\
> > > +	int ___gu_err = __get_user(x, ptr);			\
> > > +	if (!___gu_err && test_bit(MMF_UNSTABLE, &mm->flags))	\
> > 
> > test_bit is somewhat expensive. See my old mail
> > 	x86/bitops: implement __test_bit
> 
> Do you have a msg_id?

Found it
http://lkml.kernel.org/r/1440776707-22016-1-git-send-email-mst@redhat.com
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
