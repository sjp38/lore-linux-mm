Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id AE79C6B002C
	for <linux-mm@kvack.org>; Sun, 16 Oct 2011 04:01:43 -0400 (EDT)
Received: by bkbzu5 with SMTP id zu5so5312960bkb.14
        for <linux-mm@kvack.org>; Sun, 16 Oct 2011 01:01:39 -0700 (PDT)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH 2/9] mm: alloc_contig_freed_pages() added
References: <1317909290-29832-1-git-send-email-m.szyprowski@samsung.com>
 <1317909290-29832-3-git-send-email-m.szyprowski@samsung.com>
 <20111014162933.d8fead58.akpm@linux-foundation.org>
Date: Sun, 16 Oct 2011 10:01:36 +0200
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.v3fpwyxc3l0zgt@mpn-glaptop>
In-Reply-To: <20111014162933.d8fead58.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel
 Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Arnd
 Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan
 Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>

On Sat, 15 Oct 2011 01:29:33 +0200, Andrew Morton <akpm@linux-foundation=
.org> wrote:

> On Thu, 06 Oct 2011 15:54:42 +0200
> Marek Szyprowski <m.szyprowski@samsung.com> wrote:
>
>> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>
>> This commit introduces alloc_contig_freed_pages() function
>
> The "freed" seems redundant to me.  Wouldn't "alloc_contig_pages" be a=

> better name?

The =E2=80=9Cfreed=E2=80=9D is there because the function operates on pa=
ges that are in
buddy system, ie. it is given a range of PFNs that are to be removed
 from buddy system.

There's also a alloc_contig_range() function (added by next patch)
which frees pages in given range and then calls
alloc_contig_free_pages() to allocate them.

IMO, if there was an alloc_contig_pages() function, it would have to
be one level up (ie. it would figure out where to allocate memory and
then call alloc_contig_range()).  (That's really what CMA is doing).

Still, as I think of it now, maybe alloc_contig_free_range() would be
better?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
