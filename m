Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6A2F96B0253
	for <linux-mm@kvack.org>; Fri, 12 Aug 2016 05:43:22 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id l4so2486447wml.0
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 02:43:22 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id lf2si6310493wjc.11.2016.08.12.02.43.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Aug 2016 02:43:21 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id i138so1853591wmf.3
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 02:43:20 -0700 (PDT)
Date: Fri, 12 Aug 2016 11:43:19 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 09/10] vhost, mm: make sure that oom_reaper doesn't reap
 memory read by vhost
Message-ID: <20160812094319.GG3639@dhcp22.suse.cz>
References: <1469734954-31247-1-git-send-email-mhocko@kernel.org>
 <1469734954-31247-10-git-send-email-mhocko@kernel.org>
 <20160728233359-mutt-send-email-mst@kernel.org>
 <20160729060422.GA5504@dhcp22.suse.cz>
 <20160729161039-mutt-send-email-mst@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160729161039-mutt-send-email-mst@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>

On Fri 29-07-16 16:14:10, Michael S. Tsirkin wrote:
> On Fri, Jul 29, 2016 at 08:04:22AM +0200, Michal Hocko wrote:
> > On Thu 28-07-16 23:41:53, Michael S. Tsirkin wrote:
[...]
> > > 
> > > > +	 */
> > > > +	set_bit(MMF_UNSTABLE, &mm->flags);
> > > > +
> > > 
> > > I would really prefer a callback that vhost would register
> > > and stop all accesses. Tell me if you need help on above idea.
> > 
> > 
> > Well, in order to make callback workable the oom reaper would have to
> > synchronize with the said callback until it declares all currently
> > ongoing accesses done. That means oom reaper would have to block/wait
> > and that is something I would really like to prevent from because it
> > just adds another possibility of the lockup (say the get_user cannot
> > make forward progress because it is stuck in the page fault allocating
> > memory). Or do you see any other way how to implement such a callback
> > mechanism without blocking on the oom_reaper side?
> 
> I'll think it over and respond.

ping?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
