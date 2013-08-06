Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 132E36B0031
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 14:11:39 -0400 (EDT)
Date: Tue, 6 Aug 2013 12:39:02 -0400
From: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>
Subject: Re: [RFC PATCH 0/6] Improving munlock() performance for large
 non-THP areas
Message-ID: <20130806163902.GC10535@logfs.org>
References: <1375713125-18163-1-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1375713125-18163-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: mgorman@suse.de, linux-mm@kvack.org

On Mon, 5 August 2013 16:31:59 +0200, Vlastimil Babka wrote:
> 
> timedmunlock
>                             3.11-rc3              3.11-rc3              3.11-rc3              3.11-rc3              3.11-rc3              3.11-rc3              3.11-rc3
>                                    0                     1                     2                     3                     4                     5                     6
> Elapsed min           3.38 (  0.00%)        3.39 ( -0.14%)        3.00 ( 11.35%)        2.73 ( 19.48%)        2.72 ( 19.50%)        2.34 ( 30.78%)        2.16 ( 36.23%)
> Elapsed mean          3.39 (  0.00%)        3.39 ( -0.05%)        3.01 ( 11.25%)        2.73 ( 19.54%)        2.73 ( 19.41%)        2.36 ( 30.30%)        2.17 ( 36.00%)
> Elapsed stddev        0.01 (  0.00%)        0.00 ( 71.98%)        0.01 (-71.14%)        0.00 ( 89.12%)        0.01 (-48.55%)        0.03 (-277.27%)        0.01 (-85.75%)
> Elapsed max           3.41 (  0.00%)        3.40 (  0.39%)        3.04 ( 10.81%)        2.73 ( 19.96%)        2.76 ( 19.09%)        2.43 ( 28.64%)        2.20 ( 35.41%)
> Elapsed range         0.02 (  0.00%)        0.01 ( 74.99%)        0.04 (-66.12%)        0.00 ( 88.12%)        0.03 (-39.24%)        0.09 (-274.85%)        0.04 (-81.04%)
> 
> 
> Vlastimil Babka (6):
>   mm: putback_lru_page: remove unnecessary call to page_lru_base_type()
>   mm: munlock: remove unnecessary call to lru_add_drain()
>   mm: munlock: batch non-THP page isolation and munlock+putback using
>     pagevec
>   mm: munlock: batch NR_MLOCK zone state updates
>   mm: munlock: bypass per-cpu pvec for putback_lru_page
>   mm: munlock: remove redundant get_page/put_page pair on the fast path
> 
>  mm/mlock.c  | 259 ++++++++++++++++++++++++++++++++++++++++++++++++++----------
>  mm/vmscan.c |  12 +--
>  2 files changed, 224 insertions(+), 47 deletions(-)

Finally walked through 5/6 as well.  The entire patchset looks good to
me.  Feel free to attach my Reviewed-By: to the patchset.

JA?rn

--
tglx1 thinks that joern should get a (TM) for "Thinking Is Hard"
-- Thomas Gleixner

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
