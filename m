Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3B16E6B0033
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 11:08:25 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id v78so5534134pfk.8
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 08:08:25 -0700 (PDT)
Received: from mailout2.samsung.com (mailout2.samsung.com. [203.254.224.25])
        by mx.google.com with ESMTPS id g13si2707897plk.466.2017.11.02.08.08.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Nov 2017 08:08:24 -0700 (PDT)
Received: from epcas5p4.samsung.com (unknown [182.195.41.42])
	by mailout2.samsung.com (KnoxPortal) with ESMTP id 20171102150821epoutp02e4e4583e6a55a67a16b9283ccd05cf1c~zTU71g-CP2566625666epoutp02g
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 15:08:21 +0000 (GMT)
Mime-Version: 1.0
Subject: Re: [PATCH] zswap: Same-filled pages handling
Reply-To: srividya.dr@samsung.com
From: Srividya Desireddy <srividya.dr@samsung.com>
In-Reply-To: <20171019010841.GA17308@bombadil.infradead.org>
Message-ID: <20171102150820epcms5p307052ef7697592b3b4e2848bf4968f7b@epcms5p3>
Date: Thu, 02 Nov 2017 15:08:20 +0000
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset="utf-8"
References: <20171019010841.GA17308@bombadil.infradead.org>
	<20171018104832epcms5p1b2232e2236258de3d03d1344dde9fce0@epcms5p1>
	<CAGqmi75Y9wbwBS0ZythcNF1gi6bW7g_XcuMDgLu=Nx4=pWC8Jw@mail.gmail.com>
	<CGME20171018104832epcms5p1b2232e2236258de3d03d1344dde9fce0@epcms5p3>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "sjenning@redhat.com" <sjenning@redhat.com>, Matthew Wilcox <willy@infradead.org>, Timofey Titovets <nefelim4ag@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "penberg@kernel.org" <penberg@kernel.org>, Dinakar Reddy Pathireddy <dinakar.p@samsung.com>, SHARAN ALLUR <sharan.allur@samsung.com>, RAJIB BASU <rajib.basu@samsung.com>, JUHUN KIM <juhunkim@samsung.com>, "srividya.desireddy@gmail.com" <srividya.desireddy@gmail.com>

 
On Wed, Oct 19, 2017 at 6:38 AM, Matthew Wilcox wrote: 
> On Thu, Oct 19, 2017 at 12:31:18AM +0300, Timofey Titovets wrote:
>> > +static void zswap_fill_page(void *ptr, unsigned long value)
>> > +{
>> > +       unsigned int pos;
>> > +       unsigned long *page;
>> > +
>> > +       page = (unsigned long *)ptr;
>> > +       if (value == 0)
>> > +               memset(page, 0, PAGE_SIZE);
>> > +       else {
>> > +               for (pos = 0; pos < PAGE_SIZE / sizeof(*page); pos++)
>> > +                       page[pos] = value;
>> > +       }
>> > +}
>> 
>> Same here, but with memcpy().
>
>No.  Use memset_l which is optimised for this specific job.

I have tested this patch using memset_l() function in zswap_fill_page() on 
x86 64-bit system with 2GB RAM. The performance remains same. 
But, memset_l() funcion might be optimised in future. 
@Seth Jennings/Dan Streetman:  Should I use memset_l() function in this patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
