Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B4DB16B0005
	for <linux-mm@kvack.org>; Tue, 20 Feb 2018 10:04:52 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id y25so5013860pfe.5
        for <linux-mm@kvack.org>; Tue, 20 Feb 2018 07:04:52 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g17si103246pfj.154.2018.02.20.07.04.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 20 Feb 2018 07:04:51 -0800 (PST)
Date: Tue, 20 Feb 2018 07:04:49 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] slab: fix /proc/slabinfo alignment
Message-ID: <20180220150449.GF21243@bombadil.infradead.org>
References: <BM1PR0101MB2083C73A6E7608B630CE4C26B1CF0@BM1PR0101MB2083.INDPRD01.PROD.OUTLOOK.COM>
 <alpine.DEB.2.20.1802200855300.28634@nuc-kabylake>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1802200855300.28634@nuc-kabylake>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: ? ? <mordorw@hotmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Feb 20, 2018 at 08:56:11AM -0600, Christopher Lameter wrote:
> On Tue, 20 Feb 2018, ? ? wrote:
> 
> > /proc/slabinfo is not aligned, it is difficult to read, so correct it
> 
> How does it look on a terminal with 80 characters per line?

That ship sailed long ago ...

kmalloc-8192         433    435   8192    1    2 : tunables    8    4    0 : sla
bdata    433    435      0

(I put in a manual carriage return at 80 columns for those not reading on
an 80 column terminal).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
