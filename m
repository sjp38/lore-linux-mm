Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 851286B01AF
	for <linux-mm@kvack.org>; Wed,  9 Jun 2010 12:26:53 -0400 (EDT)
Received: by bwz1 with SMTP id 1so2038874bwz.14
        for <linux-mm@kvack.org>; Wed, 09 Jun 2010 09:26:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1006091112120.21686@router.home>
References: <20100521211452.659982351@quilx.com>
	<20100521211540.439539135@quilx.com>
	<alpine.DEB.2.00.1006082311130.28827@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1006091112120.21686@router.home>
Date: Wed, 9 Jun 2010 19:26:50 +0300
Message-ID: <AANLkTinCW0Bt_avQqDuGUouZTXbSKrEBx3ICcqKpmj9v@mail.gmail.com>
Subject: Re: [RFC V2 SLEB 06/14] SLUB: Get rid of the kmalloc_node slab
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Christoph,

On Wed, Jun 9, 2010 at 7:14 PM, Christoph Lameter
<cl@linux-foundation.org> wrote:
> The patch needs a rework since it sometimes calculates the wrong kmalloc
> slab. Value needs to be rounded up to the next kmalloc slab size. This
> problem shows up if CONFIG_SLUB_DEBUG is enabled.
>
> Please do not merge patches that are marked "RFC". That usually means
> that I am not satisfied with their quality yet.

I actually _asked_ you whether or not it's OK to merge patches 1-5. Do
you want to guess what you said? I have it all in writing stashed in
my mailbox if you want to refresh your memory. ;-)

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
