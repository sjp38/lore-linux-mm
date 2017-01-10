Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 373F96B0033
	for <linux-mm@kvack.org>; Tue, 10 Jan 2017 18:52:34 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id c73so30938112pfb.7
        for <linux-mm@kvack.org>; Tue, 10 Jan 2017 15:52:34 -0800 (PST)
Received: from mail-pf0-x22f.google.com (mail-pf0-x22f.google.com. [2607:f8b0:400e:c00::22f])
        by mx.google.com with ESMTPS id m1si3713909pge.100.2017.01.10.15.52.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jan 2017 15:52:33 -0800 (PST)
Received: by mail-pf0-x22f.google.com with SMTP id f144so45179839pfa.2
        for <linux-mm@kvack.org>; Tue, 10 Jan 2017 15:52:33 -0800 (PST)
Date: Tue, 10 Jan 2017 15:52:31 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, thp: add new background defrag option
In-Reply-To: <a00566c2-6fe4-90ce-6689-476619c556b8@suse.cz>
Message-ID: <alpine.DEB.2.10.1701101547560.32737@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1701041532040.67903@chino.kir.corp.google.com> <20170105101330.bvhuglbbeudubgqb@techsingularity.net> <fe83f15e-2d9f-e36c-3a89-ce1a2b39e3ca@suse.cz> <alpine.DEB.2.10.1701051446140.19790@chino.kir.corp.google.com>
 <558ce85c-4cb4-8e56-6041-fc4bce2ee27f@suse.cz> <alpine.DEB.2.10.1701061407300.138109@chino.kir.corp.google.com> <baeae644-30c4-5f99-2f99-6042766d7885@suse.cz> <alpine.DEB.2.10.1701091818340.61862@chino.kir.corp.google.com> <alpine.LSU.2.11.1701091925170.2692@eggly.anvils>
 <a00566c2-6fe4-90ce-6689-476619c556b8@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 10 Jan 2017, Vlastimil Babka wrote:

> > I get very confused by the /sys/kernel/mm/transparent_hugepage/defrag
> > versus enabled flags, and this may be a terrible, even more confusing,
> > idea: but I've been surprised and sad to see defrag with a "defer"
> > option, but poor enabled without one; and it has crossed my mind that
> > perhaps the peculiar "madvise+defer" syntax in defrag might rather be
> > handled by "madvise" in defrag with "defer" in enabled?  Or something
> > like that: 4 x 4 possibilities instead of 5 x 3.
> 
> But would all the possibilities make sense? For example, if I saw
> "defer" in enabled, my first expectation would be that it would only use
> khugepaged, and no THP page faults at all - possibly including madvised
> regions.
> 

And this is why I've tried to minimize the config requirements and respect 
userspace decisions to do MADV_HUGEPAGE, MADV_NOHUGEPAGE, or set/clear 
PR_SET_THP_DISABLE because all these system-wide options combined with 
userspace syscalls truly seems unmaintainable and waay too confusing to 
correctly describe.  Owell, I am fine with introducing 
yet-another-defrag-mode if it lets us move in a direction that supports 
our usecase.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
