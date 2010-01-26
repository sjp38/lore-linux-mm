Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 08D236B00AA
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 15:50:51 -0500 (EST)
Subject: Re: BUG at mm/slab.c:2990 with 2.6.33-rc5-tuxonice
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <4B5F52FE.5000201@crca.org.au>
References: <74fd948d1001261121r7e6d03a4i75ce40705abed4e0@mail.gmail.com>
	 <4B5F52FE.5000201@crca.org.au>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 26 Jan 2010 14:50:45 -0600
Message-ID: <1264539045.3536.1348.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nigel Cunningham <ncunningham@crca.org.au>
Cc: Pedro Ribeiro <pedrib@gmail.com>, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, "linux-mm@kvack.org >> linux-mm" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2010-01-27 at 07:39 +1100, Nigel Cunningham wrote:
> Hi.
> 
> Pedro Ribeiro wrote:
> > Hi,
> > 
> > I hit a bug at mm/slab.c:2990 with .33-rc5.
> > Unfortunately nothing more is available than a screen picture with a
> > crash dump, although it is a good one.
> > The bug was hit almost at the end of a hibernation cycle with
> > Tux-on-Ice, while saving memory contents to an encrypted swap
> > partition.
> > 
> > The image is here http://img264.imageshack.us/img264/9634/mmslab.jpg (150 kb)
> > 
> > Hopefully it is of any use for you. Please let me know if you need any
> > more info.
> 
> Looks to me to be completely unrelated to TuxOnIce - at least at a first
> glance.
> 
> Ccing the slab allocator maintainers listed in MAINTAINERS.

Not sure if this will do us any good, it's the second oops.

-- 
http://selenic.com : development and support for Mercurial and Linux

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
