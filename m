Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 3DEC66B0031
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 10:41:33 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id x10so970363pdj.29
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 07:41:32 -0700 (PDT)
Date: Wed, 2 Oct 2013 14:41:29 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: Proper kmemleak tracking if CONFIG_SLUB_DEBUG
 disabled
In-Reply-To: <5245ECC3.8070200@gmail.com>
Message-ID: <00000141799dd4b3-f6df96c0-1003-427d-9bd8-f6455622f4ea-000000@email.amazonses.com>
References: <5245ECC3.8070200@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frank Rowand <frowand.list@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, Linux Kernel list <linux-kernel@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, "Bobniev, Roman" <Roman.Bobniev@sonymobile.com>, "Bird, Tim" <Tim.Bird@sonymobile.com>, =?ISO-8859-15?Q?=22Andersson=2C_Bj=F6rn=22?= <Bjorn.Andersson@sonymobile.com>

On Fri, 27 Sep 2013, Frank Rowand wrote:

> Move the kmemleak code for small block allocation out from
> under CONFIG_SLUB_DEBUG.

Well in that case it may be better to move the hooks as a whole out of
the CONFIG_SLUB_DEBUG section. Do the #ifdeffering for each call from the
hooks instead.

The point of the hook functions is to separate the hooks out of the
functions so taht they do not accumulate in the main code.

The patch moves one hook back into the main code. Please keep the checks
in the hooks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
