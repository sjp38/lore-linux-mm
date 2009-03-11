Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 02FB56B003D
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 06:33:19 -0400 (EDT)
Received: by fg-out-1718.google.com with SMTP id 19so971485fgg.4
        for <linux-mm@kvack.org>; Wed, 11 Mar 2009 03:33:18 -0700 (PDT)
Date: Wed, 11 Mar 2009 13:40:18 +0300
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH 1/2] mm: use list.h for vma list
Message-ID: <20090311104018.GA2376@x200.localdomain>
References: <8c5a844a0903110255q45b7cdf4u1453ce40d495ee2c@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8c5a844a0903110255q45b7cdf4u1453ce40d495ee2c@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Daniel Lowengrub <lowdanie@gmail.com>
Cc: linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>, a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 11, 2009 at 11:55:48AM +0200, Daniel Lowengrub wrote:
> Use the linked list defined list.h for the list of vmas that's stored
> in the mm_struct structure.  Wrapper functions "vma_next" and
> "vma_prev" are also implemented.  Functions that operate on more than
> one vma are now given a list of vmas as input.

> Signed-off-by: Daniel Lowengrub

That's not how S-o-b line should look like.

> --- linux-2.6.28.7.vanilla/arch/alpha/kernel/osf_sys.c
> +++ linux-2.6.28.7/arch/alpha/kernel/osf_sys.c
> @@ -1197,7 +1197,7 @@
>  		if (!vma || addr + len <= vma->vm_start)
>  			return addr;
>  		addr = vma->vm_end;
> -		vma = vma->vm_next;
> +		vma = vma_next(vma);

Well, this bloats both mm_struct and vm_area_struct.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
