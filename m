Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 11A718D0030
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 23:55:14 -0400 (EDT)
Received: by qwi2 with SMTP id 2so2718785qwi.14
        for <linux-mm@kvack.org>; Thu, 28 Oct 2010 20:55:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20101026190809.4869b4f0.kamezawa.hiroyu@jp.fujitsu.com>
References: <20101026190042.57f30338.kamezawa.hiroyu@jp.fujitsu.com>
	<20101026190809.4869b4f0.kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 29 Oct 2010 11:55:10 +0800
Message-ID: <AANLkTik-d4-6xN6BFYNcAOyR3P7uJDB-0ucr6Uks3AXv@mail.gmail.com>
Subject: Re: [RFC][PATCH 3/3] a big contig memory allocator
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, andi.kleen@intel.com, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, fujita.tomonori@lab.ntt.co.jp, felipe.contreras@gmail.com
List-ID: <linux-mm.kvack.org>

On Tue, Oct 26, 2010 at 6:08 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> Add an function to allocate contiguous memory larger than MAX_ORDER.
> The main difference between usual page allocator is that this uses
> memory offline technique (Isolate pages and migrate remaining pages.).
>
> I think this is not 100% solution because we can't avoid fragmentation,
> but we have kernelcore=3D boot option and can create MOVABLE zone. That
> helps us to allow allocate a contiguous range on demand.
>
> The new function is
>
> =C2=A0alloc_contig_pages(base, end, nr_pages, alignment)
>
> This function will allocate contiguous pages of nr_pages from the range
> [base, end). If [base, end) is bigger than nr_pages, some pfn which
> meats alignment will be allocated. If alignment is smaller than MAX_ORDER=
,
> it will be raised to be MAX_ORDER.
>
> __alloc_contig_pages() has much more arguments.
>
> Some drivers allocates contig pages by bootmem or hiding some memory
> from the kernel at boot. But if contig pages are necessary only in some
> situation, kernelcore=3D boot option and using page migration is a choice=
