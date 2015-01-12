Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 50C596B0032
	for <linux-mm@kvack.org>; Mon, 12 Jan 2015 12:35:18 -0500 (EST)
Received: by mail-wg0-f48.google.com with SMTP id l2so20686628wgh.7
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 09:35:18 -0800 (PST)
Received: from mail-wi0-x229.google.com (mail-wi0-x229.google.com. [2a00:1450:400c:c05::229])
        by mx.google.com with ESMTPS id dk6si36864526wjb.113.2015.01.12.09.35.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 12 Jan 2015 09:35:17 -0800 (PST)
Received: by mail-wi0-f169.google.com with SMTP id n3so211588wiv.0
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 09:35:17 -0800 (PST)
Date: Mon, 12 Jan 2015 18:35:15 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -v3 5/5] oom, PM: make OOM detection in the freezer path
 raceless
Message-ID: <20150112173515.GF4877@dhcp22.suse.cz>
References: <1420801555-22659-1-git-send-email-mhocko@suse.cz>
 <1420801555-22659-6-git-send-email-mhocko@suse.cz>
 <20150110194322.GE25319@htj.dyndns.org>
 <20150112161011.GE4877@dhcp22.suse.cz>
 <20150112172251.GB22156@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150112172251.GB22156@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "\\\"Rafael J. Wysocki\\\"" <rjw@rjwysocki.net>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Oleg Nesterov <oleg@redhat.com>, Cong Wang <xiyou.wangcong@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-pm@vger.kernel.org

On Mon 12-01-15 12:22:51, Tejun Heo wrote:
> On Mon, Jan 12, 2015 at 05:10:11PM +0100, Michal Hocko wrote:
> > Yes I had it this way but it didn't work out because thaw_kernel_threads
> > is not called on the resume because it is only used as a fail
> > path when kernel threads freezing fails. I would rather keep the
> 
> Ooh, that's kinda asymmetric.
> 
> > enabling/disabling points as we had them. This is less risky IMHO.
> 
> Okay, please feel free to add
> 
>  Acked-by: Tejun Heo <tj@kernel.org>

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
