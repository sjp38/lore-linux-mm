Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 3C86C6B0005
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 23:46:33 -0400 (EDT)
Received: by mail-qa0-f44.google.com with SMTP id o13so69529qaj.10
        for <linux-mm@kvack.org>; Wed, 10 Apr 2013 20:46:32 -0700 (PDT)
Message-ID: <51663210.7070502@gmail.com>
Date: Thu, 11 Apr 2013 11:46:24 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] mm, slub: count freed pages via rcu as this task's
 reclaimed_slab
References: <1365470478-645-1-git-send-email-iamjoonsoo.kim@lge.com> <1365470478-645-2-git-send-email-iamjoonsoo.kim@lge.com> <5163E194.3080600@gmail.com> <0000013def363b50-9a16dd09-72ad-494f-9c25-17269fc3aab3-000000@email.amazonses.com> <5164DA6A.5060607@gmail.com> <0000013df43a48e5-6addd57e-952b-4754-848e-6d454b0a906c-000000@email.amazonses.com>
In-Reply-To: <0000013df43a48e5-6addd57e-952b-4754-848e-6d454b0a906c-000000@email.amazonses.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>

Hi Christoph,
On 04/10/2013 09:54 PM, Christoph Lameter wrote:
> On Wed, 10 Apr 2013, Simon Jeons wrote:
>
>> It seems that you misunderstand my question. I don't doubt slab/slub can use
>> high order pages. However, what I focus on is why slab/slub can use compound
>> page, PageCompound() just on behalf of hugetlbfs pages or thp pages which
>> should used by apps, isn't it?
> I am not entirely clear on what you are asking for. The following gives a
> couple of answers to what I guess the question was.
>
> THP pages and user pages are on the lru and are managed differently.
> The slab allocators cannot work with those pages.
>
> Slab allocators *can* allocate higher order pages therefore they could
> allocate a page of the same order as huge pages and manage it that way.
>
> However there is no way that these pages could be handled like THP pages
> since they cannot be broken up (unless we add the capability to move slab
> objects which I wanted to do for a long time).
>
>
> You can boot a Linux system that uses huge pages for slab allocation
> by specifying the following parameter on the kernel command line.
>
> 	slub_min_order=9
>
> The slub allocator will start using huge pages for all its storage
> needs. You need a large number of huge pages to do this. Lots of memory
> is going to be lost due to fragmentation but its going to be fast since
> the slowpaths are rarely used. OOMs due to reclaim failure become much
> more likely ;-).
>

It seems that I need to simple my question.
All pages which order >=1 are compound pages?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
