Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id EA50C6B025E
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 02:34:29 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ao6so70102529pac.2
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 23:34:29 -0700 (PDT)
Received: from mail-pf0-f195.google.com (mail-pf0-f195.google.com. [209.85.192.195])
        by mx.google.com with ESMTPS id iu4si8713277pac.93.2016.06.15.23.34.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jun 2016 23:34:29 -0700 (PDT)
Received: by mail-pf0-f195.google.com with SMTP id c74so3363637pfb.0
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 23:34:29 -0700 (PDT)
Date: Thu, 16 Jun 2016 08:34:26 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/10 -v4] Handle oom bypass more gracefully
Message-ID: <20160616063426.GE30768@dhcp22.suse.cz>
References: <1465473137-22531-1-git-send-email-mhocko@kernel.org>
 <20160615150903.GE7944@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160615150903.GE7944@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Wed 15-06-16 17:09:03, Oleg Nesterov wrote:
> On 06/09, Michal Hocko wrote:
> >
> > this is the v4 version of the patchse.
> 
> I would like to ack this series even if I do not pretend I understand
> all implications.
> 
> But imo every change makes sense and this version adresses my previous
> comments, so FWIW:

Thanks for the review Oleg!
 
> Acked-by: Oleg Nesterov <oleg@redhat.com>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
