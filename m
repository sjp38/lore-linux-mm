Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id D567A6B025E
	for <linux-mm@kvack.org>; Tue, 10 Jan 2017 03:44:40 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id c85so19693361wmi.6
        for <linux-mm@kvack.org>; Tue, 10 Jan 2017 00:44:40 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k188si12408438wmd.64.2017.01.10.00.44.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 Jan 2017 00:44:39 -0800 (PST)
Subject: Re: [patch] mm, thp: add new background defrag option
References: <alpine.DEB.2.10.1701041532040.67903@chino.kir.corp.google.com>
 <20170105101330.bvhuglbbeudubgqb@techsingularity.net>
 <fe83f15e-2d9f-e36c-3a89-ce1a2b39e3ca@suse.cz>
 <alpine.DEB.2.10.1701051446140.19790@chino.kir.corp.google.com>
 <558ce85c-4cb4-8e56-6041-fc4bce2ee27f@suse.cz>
 <alpine.DEB.2.10.1701061407300.138109@chino.kir.corp.google.com>
 <baeae644-30c4-5f99-2f99-6042766d7885@suse.cz>
 <alpine.DEB.2.10.1701091818340.61862@chino.kir.corp.google.com>
 <alpine.LSU.2.11.1701091925170.2692@eggly.anvils>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <a00566c2-6fe4-90ce-6689-476619c556b8@suse.cz>
Date: Tue, 10 Jan 2017 09:44:37 +0100
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1701091925170.2692@eggly.anvils>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 01/10/2017 04:38 AM, Hugh Dickins wrote:
> On Mon, 9 Jan 2017, David Rientjes wrote:
>> On Mon, 9 Jan 2017, Vlastimil Babka wrote:
>>
>>>> Any suggestions for a better name for "background" are more than welcome.  
>>>
>>> Why not just "madvise+defer"?
>>>
>>
>> Seeing no other activity regarding this issue (omg!), I'll wait a day or 
>> so to see if there are any objections to "madvise+defer" or suggestions 
>> that may be better and repost.
> 
> I get very confused by the /sys/kernel/mm/transparent_hugepage/defrag
> versus enabled flags, and this may be a terrible, even more confusing,
> idea: but I've been surprised and sad to see defrag with a "defer"
> option, but poor enabled without one; and it has crossed my mind that
> perhaps the peculiar "madvise+defer" syntax in defrag might rather be
> handled by "madvise" in defrag with "defer" in enabled?  Or something
> like that: 4 x 4 possibilities instead of 5 x 3.

But would all the possibilities make sense? For example, if I saw
"defer" in enabled, my first expectation would be that it would only use
khugepaged, and no THP page faults at all - possibly including madvised
regions.

If we really wanted really to cover the whole configuration space, we
would have files called "enable", "defrag", "enable-madvise",
"defrag-madvise" and each with possible values "yes", "no", "defer",
where "defer" for enable* files would mean to skip THP page fault
completely and defer to khugepaged, and "defer" for defrag* files would
mean wake up kswapd/kcompactd and skip direct reclaim/compaction.

But, too late for that :)

> 
> Please be gentle with me,
> Hugh
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
