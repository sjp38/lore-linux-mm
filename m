Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 039E56B0039
	for <linux-mm@kvack.org>; Mon, 30 Sep 2013 05:04:43 -0400 (EDT)
Received: by mail-pb0-f54.google.com with SMTP id ro12so5356445pbb.27
        for <linux-mm@kvack.org>; Mon, 30 Sep 2013 02:04:43 -0700 (PDT)
Date: Mon, 30 Sep 2013 10:04:11 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] slub: Proper kmemleak tracking if CONFIG_SLUB_DEBUG
 disabled
Message-ID: <20130930090410.GB17042@arm.com>
References: <5245ECC3.8070200@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5245ECC3.8070200@gmail.com>
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frank Rowand <frowand.list@gmail.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, "Bobniev, Roman" <Roman.Bobniev@sonymobile.com>, "Bird, Tim" <Tim.Bird@sonymobile.com>, =?iso-8859-1?Q?Andersson=2C_Bj=F6rn?= <Bjorn.Andersson@sonymobile.com>

On Fri, Sep 27, 2013 at 09:38:27PM +0100, Frank Rowand wrote:
> From: Roman Bobniev <roman.bobniev@sonymobile.com>
> 
> When kmemleak checking is enabled and CONFIG_SLUB_DEBUG is
> disabled, the kmemleak code for small block allocation is
> disabled.  This results in false kmemleak errors when memory
> is freed.
> 
> Move the kmemleak code for small block allocation out from
> under CONFIG_SLUB_DEBUG.
> 
> Signed-off-by: Roman Bobniev <roman.bobniev@sonymobile.com>
> Signed-off-by: Frank Rowand <frank.rowand@sonymobile.com>

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
