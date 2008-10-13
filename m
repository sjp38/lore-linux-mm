Message-ID: <48F372BA.7020505@linux-foundation.org>
Date: Mon, 13 Oct 2008 09:09:30 -0700
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: use a radix-tree to make do_move_pages() complexity
 linear
References: <48EDF9DA.7000508@inria.fr> <20081010125010.164bcbb8.akpm@linux-foundation.org> <48EFB6E6.4080708@inria.fr> <48EFBBE9.5000703@linux-foundation.org> <48F069B8.6050709@inria.fr>
In-Reply-To: <48F069B8.6050709@inria.fr>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Brice Goglin <Brice.Goglin@inria.fr>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, nathalie.furmento@labri.fr
List-ID: <linux-mm.kvack.org>

Brice Goglin wrote:
> * One thing that bothers me is move_pages() returning -ENOENT when no
> page are given to migrate_pages(). I don't see why having 100/100 pages
> not migrated would return a different error than having only 99/100
> pages not migrated. We have the status array to place -ENOENT for all
> these pages. If the user doesn't know where his pages are allocated, he
> shouldn't get a different return value depending on how many pages were
> already on the right node. And actually, this convention makes
> user-space application harder to write since you need to treat -ENOENT
> as a success unless you already knew for sure where your pages were
> allocated. And the big thing is that this convention makes the chunking
> painfully/uselessly more complex. Breaking user-ABI is bad, but fixing
> crazy ABI...
>   
I do not think that move_pages() is used that frequently. Changing the 
API slightly as you suggest would not be that big of a deal.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
