Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id B99B06B002B
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 15:02:07 -0400 (EDT)
Date: Tue, 16 Oct 2012 19:02:06 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [Q] Default SLAB allocator
In-Reply-To: <CALF0-+XGn5=QSE0bpa4RTag9CAJ63MKz1kvaYbpw34qUhViaZA@mail.gmail.com>
Message-ID: <0000013a6af44832-54f34e60-0e9d-4534-a509-f4171a505671-000000@email.amazonses.com>
References: <CALF0-+XGn5=QSE0bpa4RTag9CAJ63MKz1kvaYbpw34qUhViaZA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ezequiel Garcia <elezegarcia@gmail.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Tim Bird <tim.bird@am.sony.com>, celinux-dev@lists.celinuxforum.org

On Thu, 11 Oct 2012, Ezequiel Garcia wrote:

> * Is SLAB a proper choice? or is it just historical an never been re-evaluated?
> * Does the average embedded guy knows which allocator to choose
>   and what's the impact on his platform?

My current ideas on this subject matter is to get to a point where we have
a generic slab allocator framework that allows us to provide any
object layout we want. This will simplify handling new slab allocators that
seems to crop up frequently. Maybe even allow the specification of the
storage layout when the slab is created. Depending on how the memory is
used there may be different object layouts that are most advantageous.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
