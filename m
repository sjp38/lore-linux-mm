Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 741916B0038
	for <linux-mm@kvack.org>; Mon,  9 Jan 2017 07:06:55 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id w13so14699009wmw.0
        for <linux-mm@kvack.org>; Mon, 09 Jan 2017 04:06:55 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id go16si96452262wjc.76.2017.01.09.04.06.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 09 Jan 2017 04:06:54 -0800 (PST)
Subject: Re: [patch] mm, thp: add new background defrag option
References: <alpine.DEB.2.10.1701041532040.67903@chino.kir.corp.google.com>
 <20170105101330.bvhuglbbeudubgqb@techsingularity.net>
 <fe83f15e-2d9f-e36c-3a89-ce1a2b39e3ca@suse.cz>
 <alpine.DEB.2.10.1701051446140.19790@chino.kir.corp.google.com>
 <558ce85c-4cb4-8e56-6041-fc4bce2ee27f@suse.cz>
 <alpine.DEB.2.10.1701061407300.138109@chino.kir.corp.google.com>
 <baeae644-30c4-5f99-2f99-6042766d7885@suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <ef5d4749-1ba2-a53b-0e38-931b0a1428fb@suse.cz>
Date: Mon, 9 Jan 2017 13:06:44 +0100
MIME-Version: 1.0
In-Reply-To: <baeae644-30c4-5f99-2f99-6042766d7885@suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 01/09/2017 11:04 AM, Vlastimil Babka wrote:
> On 01/06/2017 11:20 PM, David Rientjes wrote:
>> I'd leave it to Andrew to decide whether sysfs files should accept 
>> multiple modes or not.  If you are to propose a patch to do so, I'd 
>> encourage you to do the same cleanup of triple_flag_store() that I did and 
>> make the gfp mask construction more straight-forward.  If you'd like to 
>> suggest a different name for "background", I'd be happy to change that if 
>> it's more descriptive.
> 
> Suggestion is above. I however think your cleanup isn't really needed,
> we can simply keep the existing 3 internal flags, and "madvise+defer"
> would enable two of them, like in my patch. Nothing says that internally
> each option should correspond to exactly one flag.

Forgot to add that if/when you repost this, please CC linux-api and
summarize what else was considered in the changelog. Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
