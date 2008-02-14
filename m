Received: by wr-out-0506.google.com with SMTP id 60so519340wri.8
        for <linux-mm@kvack.org>; Thu, 14 Feb 2008 00:57:29 -0800 (PST)
Message-ID: <84144f020802140057m5dcf479fjd71911ff573055f2@mail.gmail.com>
Date: Thu, 14 Feb 2008 10:57:28 +0200
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [patch 4/5] slub: Use __GFP_MOVABLE for slabs of HPAGE_SIZE
In-Reply-To: <20080214040314.118141086@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080214040245.915842795@sgi.com>
	 <20080214040314.118141086@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

[Sorry for the duplicate. My email client started trimming cc's...]

On Thu, Feb 14, 2008 at 6:02 AM, Christoph Lameter <clameter@sgi.com> wrote:
> This is the same trick as done by the hugetlb support in the kernel.
>  If we allocate a huge page use __GFP_MOVABLE because an allocation
>  of a HUGE_PAGE size is the large allocation unit that cannot cause
>  fragmentation.
>
>  This will make a system that was booted with
>
>         slub_min_order = 9
>
>  not have any reclaimable slab allocations anymore. All slab allocations
>  will be of type MOVABLE (although they are not movable like huge pages
>  are also not movable). This means that we only have MOVABLE and UNMOVABLE
>  sections of memory which reduces the types of sections and therefore the
>  danger of fragmenting memory.

Why does slub_min_order=9 matter? I suppose this is fixing some other
real bug?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
