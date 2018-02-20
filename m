Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 956E56B0008
	for <linux-mm@kvack.org>; Tue, 20 Feb 2018 11:05:26 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id o10so7503106iod.21
        for <linux-mm@kvack.org>; Tue, 20 Feb 2018 08:05:26 -0800 (PST)
Received: from resqmta-ch2-03v.sys.comcast.net (resqmta-ch2-03v.sys.comcast.net. [2001:558:fe21:29:69:252:207:35])
        by mx.google.com with ESMTPS id e197si61421iof.53.2018.02.20.08.05.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Feb 2018 08:05:25 -0800 (PST)
Date: Tue, 20 Feb 2018 10:05:23 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH] slab: fix /proc/slabinfo alignment
In-Reply-To: <20180220150449.GF21243@bombadil.infradead.org>
Message-ID: <alpine.DEB.2.20.1802201004480.29180@nuc-kabylake>
References: <BM1PR0101MB2083C73A6E7608B630CE4C26B1CF0@BM1PR0101MB2083.INDPRD01.PROD.OUTLOOK.COM> <alpine.DEB.2.20.1802200855300.28634@nuc-kabylake> <20180220150449.GF21243@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: ? ? <mordorw@hotmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, 20 Feb 2018, Matthew Wilcox wrote:

> On Tue, Feb 20, 2018 at 08:56:11AM -0600, Christopher Lameter wrote:
> > On Tue, 20 Feb 2018, ? ? wrote:
> >
> > > /proc/slabinfo is not aligned, it is difficult to read, so correct it
> >
> > How does it look on a terminal with 80 characters per line?
>
> That ship sailed long ago ...
>
> kmalloc-8192         433    435   8192    1    2 : tunables    8    4    0 : sla
> bdata    433    435      0
>
> (I put in a manual carriage return at 80 columns for those not reading on
> an 80 column terminal).

Well yes but if someone is fixing things then the 80 character issue also
should be fixed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
