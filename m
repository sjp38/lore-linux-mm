Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f177.google.com (mail-we0-f177.google.com [74.125.82.177])
	by kanga.kvack.org (Postfix) with ESMTP id 4784A6B0038
	for <linux-mm@kvack.org>; Mon,  2 Feb 2015 03:37:22 -0500 (EST)
Received: by mail-we0-f177.google.com with SMTP id l61so37507963wev.8
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 00:37:21 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hq9si3120590wjb.146.2015.02.02.00.37.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Feb 2015 00:37:20 -0800 (PST)
Message-ID: <54CF373E.4090200@suse.cz>
Date: Mon, 02 Feb 2015 09:37:18 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [LSF/MM TOPIC ATTEND] - THP benefits
References: <20150106161435.GF20860@dhcp22.suse.cz>
In-Reply-To: <20150106161435.GF20860@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>

On 01/06/2015 05:14 PM, Michal Hocko wrote:
> - THP success rate has become one of the metric for reclaim/compaction
>   changes which I feel is missing one important aspect and that is
>   cost/benefit analysis. It might be better to have more THP pages in
>   some loads but the whole advantage might easily go away when the
>   initial cost is higher than all aggregated saves. When it comes to
>   benchmarks and numbers we are usually missing the later.

So what I think would help in this discussion is some numbers on how much
hugepages (thus THP) actually help performance nowadays. Does anyone have such
results on recent hardware from e.g. SPEC CPU2006 or even production workloads?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
