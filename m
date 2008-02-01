Date: Thu, 31 Jan 2008 23:55:44 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] NULL pointer check for vma->vm_mm
Message-Id: <20080131235544.346b938a.akpm@linux-foundation.org>
In-Reply-To: <3fd7d7a70801312339p2a142096p83ed286c81379728@mail.gmail.com>
References: <3fd7d7a70801312339p2a142096p83ed286c81379728@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kenichi Okuyama <kenichi.okuyama@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 1 Feb 2008 16:39:07 +0900 "Kenichi Okuyama" <kenichi.okuyama@gmail.com> wrote:

> Dear all,
> 
> I was looking at the ./mm/rmap.c .. I found that, in function
> "page_referenced_one()",
>    struct mm_struct *mm = vma->vm_mm;
> was being refererred without NULL check.
> 
> Though I do agree that this works for most of the cases, I thought it
> is better to add
> BUG_ON() for case of mm being NULL.
> 
> attached is the patch for this

If we dereference NULL then the kernel will display basically the same
information as would a BUG, and it takes the same action.  So adding a
BUG_ON here really doesn't gain us anything.

Also, I think vma->vm_mm == 0 is not a valid state, so this just shouldn't
happen - the code is OK to assume that a particular invariant is being
honoured.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
