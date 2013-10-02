Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id D05E56B0031
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 12:24:56 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id y10so1099068pdj.8
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 09:24:56 -0700 (PDT)
Date: Wed, 2 Oct 2013 16:24:53 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: Proper kmemleak tracking if CONFIG_SLUB_DEBUG
 disabled
In-Reply-To: <20131002155417.GB29794@arm.com>
Message-ID: <0000014179fc82ac-8e47c69d-8c5a-4f75-957d-15741eb36eda-000000@email.amazonses.com>
References: <5245ECC3.8070200@gmail.com> <00000141799dd4b3-f6df96c0-1003-427d-9bd8-f6455622f4ea-000000@email.amazonses.com> <F5184659D418E34EA12B1903EE5EF5FD8538E86615@seldmbx02.corpusers.net> <20131002155417.GB29794@arm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: "Bird, Tim" <Tim.Bird@sonymobile.com>, Frank Rowand <frowand.list@gmail.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, "Bobniev, Roman" <Roman.Bobniev@sonymobile.com>, =?ISO-8859-15?Q?Andersson=2C_Bj=F6rn?= <Bjorn.Andersson@sonymobile.com>

On Wed, 2 Oct 2013, Catalin Marinas wrote:

> Kmemleak doesn't depend on SLUB_DEBUG (at least it didn't originally ;),
> so I don't think we should add an artificial dependency (or select). Can
> we have kmemleak_*() calls in both debug and !debug hooks?

Yes if you move the hook calls out from under CONFIG_SLUB_DEBUG.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
