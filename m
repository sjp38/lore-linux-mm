Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2AC686B0038
	for <linux-mm@kvack.org>; Mon,  9 Jan 2017 22:38:41 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 127so698734214pfg.5
        for <linux-mm@kvack.org>; Mon, 09 Jan 2017 19:38:41 -0800 (PST)
Received: from mail-pf0-x22f.google.com (mail-pf0-x22f.google.com. [2607:f8b0:400e:c00::22f])
        by mx.google.com with ESMTPS id p61si627124plb.159.2017.01.09.19.38.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jan 2017 19:38:40 -0800 (PST)
Received: by mail-pf0-x22f.google.com with SMTP id y143so17986677pfb.0
        for <linux-mm@kvack.org>; Mon, 09 Jan 2017 19:38:40 -0800 (PST)
Date: Mon, 9 Jan 2017 19:38:31 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [patch] mm, thp: add new background defrag option
In-Reply-To: <alpine.DEB.2.10.1701091818340.61862@chino.kir.corp.google.com>
Message-ID: <alpine.LSU.2.11.1701091925170.2692@eggly.anvils>
References: <alpine.DEB.2.10.1701041532040.67903@chino.kir.corp.google.com> <20170105101330.bvhuglbbeudubgqb@techsingularity.net> <fe83f15e-2d9f-e36c-3a89-ce1a2b39e3ca@suse.cz> <alpine.DEB.2.10.1701051446140.19790@chino.kir.corp.google.com>
 <558ce85c-4cb4-8e56-6041-fc4bce2ee27f@suse.cz> <alpine.DEB.2.10.1701061407300.138109@chino.kir.corp.google.com> <baeae644-30c4-5f99-2f99-6042766d7885@suse.cz> <alpine.DEB.2.10.1701091818340.61862@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 9 Jan 2017, David Rientjes wrote:
> On Mon, 9 Jan 2017, Vlastimil Babka wrote:
> 
> > > Any suggestions for a better name for "background" are more than welcome.  
> > 
> > Why not just "madvise+defer"?
> > 
> 
> Seeing no other activity regarding this issue (omg!), I'll wait a day or 
> so to see if there are any objections to "madvise+defer" or suggestions 
> that may be better and repost.

I get very confused by the /sys/kernel/mm/transparent_hugepage/defrag
versus enabled flags, and this may be a terrible, even more confusing,
idea: but I've been surprised and sad to see defrag with a "defer"
option, but poor enabled without one; and it has crossed my mind that
perhaps the peculiar "madvise+defer" syntax in defrag might rather be
handled by "madvise" in defrag with "defer" in enabled?  Or something
like that: 4 x 4 possibilities instead of 5 x 3.

Please be gentle with me,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
