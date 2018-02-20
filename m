Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id D660B6B002E
	for <linux-mm@kvack.org>; Tue, 20 Feb 2018 13:43:54 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id g125so12420638ita.6
        for <linux-mm@kvack.org>; Tue, 20 Feb 2018 10:43:54 -0800 (PST)
Received: from resqmta-ch2-02v.sys.comcast.net (resqmta-ch2-02v.sys.comcast.net. [2001:558:fe21:29:69:252:207:34])
        by mx.google.com with ESMTPS id i3si925325iof.237.2018.02.20.10.43.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Feb 2018 10:43:54 -0800 (PST)
Date: Tue, 20 Feb 2018 12:43:52 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH] slab: fix /proc/slabinfo alignment
In-Reply-To: <20180220183659.GA12573@bombadil.infradead.org>
Message-ID: <alpine.DEB.2.20.1802201243220.30194@nuc-kabylake>
References: <BM1PR0101MB2083C73A6E7608B630CE4C26B1CF0@BM1PR0101MB2083.INDPRD01.PROD.OUTLOOK.COM> <alpine.DEB.2.20.1802200855300.28634@nuc-kabylake> <20180220150449.GF21243@bombadil.infradead.org> <alpine.DEB.2.20.1802201004480.29180@nuc-kabylake>
 <20180220161139.GH21243@bombadil.infradead.org> <alpine.DEB.2.20.1802201022540.29313@nuc-kabylake> <20180220183659.GA12573@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: ? ? <mordorw@hotmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, 20 Feb 2018, Matthew Wilcox wrote:

> In memcg_create_kmem_cache:
>
> 	s->name = kasprintf(GFP_KERNEL, "%s(%llu:%s)", a->name,
> 				css->serial_nr, memcg_name_buf);
>

But that creates the long name that shows up in /proc/slabinfo.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
