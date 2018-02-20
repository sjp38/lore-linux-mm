Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7211E6B0005
	for <linux-mm@kvack.org>; Tue, 20 Feb 2018 11:23:43 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id l80so5942960ita.4
        for <linux-mm@kvack.org>; Tue, 20 Feb 2018 08:23:43 -0800 (PST)
Received: from resqmta-ch2-06v.sys.comcast.net (resqmta-ch2-06v.sys.comcast.net. [2001:558:fe21:29:69:252:207:38])
        by mx.google.com with ESMTPS id a138si5846874ioe.122.2018.02.20.08.23.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Feb 2018 08:23:42 -0800 (PST)
Date: Tue, 20 Feb 2018 10:23:41 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH] slab: fix /proc/slabinfo alignment
In-Reply-To: <20180220161139.GH21243@bombadil.infradead.org>
Message-ID: <alpine.DEB.2.20.1802201022540.29313@nuc-kabylake>
References: <BM1PR0101MB2083C73A6E7608B630CE4C26B1CF0@BM1PR0101MB2083.INDPRD01.PROD.OUTLOOK.COM> <alpine.DEB.2.20.1802200855300.28634@nuc-kabylake> <20180220150449.GF21243@bombadil.infradead.org> <alpine.DEB.2.20.1802201004480.29180@nuc-kabylake>
 <20180220161139.GH21243@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: ? ? <mordorw@hotmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, 20 Feb 2018, Matthew Wilcox wrote:

> I don't think it's fixable; there's just too much information per slab.
> Anyway, I preferred the solution you & I were working on to limit the
> length of names to 16 bytes, except for the cgroup slabs.

So what do we do with the cgroup slab names? have a slabinfo per cgroup?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
