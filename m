Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id CD4DC6B0069
	for <linux-mm@kvack.org>; Tue,  6 Dec 2016 03:27:42 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id xy5so68502532wjc.0
        for <linux-mm@kvack.org>; Tue, 06 Dec 2016 00:27:42 -0800 (PST)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id o76si2676093wmi.60.2016.12.06.00.27.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Dec 2016 00:27:41 -0800 (PST)
Received: by mail-wm0-f65.google.com with SMTP id a20so20043792wme.2
        for <linux-mm@kvack.org>; Tue, 06 Dec 2016 00:27:41 -0800 (PST)
Date: Tue, 6 Dec 2016 09:27:39 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm, oom: do not enfore OOM killer for __GFP_NOFAIL
 automatically
Message-ID: <20161206082738.GA18664@dhcp22.suse.cz>
References: <20161201152517.27698-1-mhocko@kernel.org>
 <20161201152517.27698-3-mhocko@kernel.org>
 <201612052245.HDB21880.OHJMOOQFFSVLtF@I-love.SAKURA.ne.jp>
 <20161205141009.GJ30758@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161205141009.GJ30758@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, hannes@cmpxchg.org, mgorman@suse.de, rientjes@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 05-12-16 15:10:09, Michal Hocko wrote:
[...]
> So we are somewhere in the middle between pre-mature and pointless
> system disruption (GFP_NOFS with a lots of metadata or lowmem request)
> where the OOM killer even might not help and potential lockup which is
> inevitable with the current design. Dunno about you but I would rather
> go with the first option. To be honest I really fail to understand your
> line of argumentation. We have this
> 	do {
> 		cond_resched();
> 	} (page = alloc_page(GFP_NOFS));

This should have been while (!(page = alloc_page(GFP_NOFS))) of
course...

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
