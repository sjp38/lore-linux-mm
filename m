Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 77FF76003C1
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 15:37:42 -0500 (EST)
Message-ID: <4B5F52FE.5000201@crca.org.au>
Date: Wed, 27 Jan 2010 07:39:26 +1100
From: Nigel Cunningham <ncunningham@crca.org.au>
MIME-Version: 1.0
Subject: Re: BUG at mm/slab.c:2990 with 2.6.33-rc5-tuxonice
References: <74fd948d1001261121r7e6d03a4i75ce40705abed4e0@mail.gmail.com>
In-Reply-To: <74fd948d1001261121r7e6d03a4i75ce40705abed4e0@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pedro Ribeiro <pedrib@gmail.com>
Cc: linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, "linux-mm@kvack.org >> linux-mm" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi.

Pedro Ribeiro wrote:
> Hi,
> 
> I hit a bug at mm/slab.c:2990 with .33-rc5.
> Unfortunately nothing more is available than a screen picture with a
> crash dump, although it is a good one.
> The bug was hit almost at the end of a hibernation cycle with
> Tux-on-Ice, while saving memory contents to an encrypted swap
> partition.
> 
> The image is here http://img264.imageshack.us/img264/9634/mmslab.jpg (150 kb)
> 
> Hopefully it is of any use for you. Please let me know if you need any
> more info.

Looks to me to be completely unrelated to TuxOnIce - at least at a first
glance.

Ccing the slab allocator maintainers listed in MAINTAINERS.

Regards,

Nigel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
