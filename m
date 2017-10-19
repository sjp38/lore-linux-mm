Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 121D26B0038
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 21:08:46 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id l24so5319893pgu.22
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 18:08:46 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id o63si7028331pfg.336.2017.10.18.18.08.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Oct 2017 18:08:44 -0700 (PDT)
Date: Wed, 18 Oct 2017 18:08:41 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] zswap: Same-filled pages handling
Message-ID: <20171019010841.GA17308@bombadil.infradead.org>
References: <CGME20171018104832epcms5p1b2232e2236258de3d03d1344dde9fce0@epcms5p1>
 <20171018104832epcms5p1b2232e2236258de3d03d1344dde9fce0@epcms5p1>
 <CAGqmi75Y9wbwBS0ZythcNF1gi6bW7g_XcuMDgLu=Nx4=pWC8Jw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGqmi75Y9wbwBS0ZythcNF1gi6bW7g_XcuMDgLu=Nx4=pWC8Jw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Timofey Titovets <nefelim4ag@gmail.com>
Cc: Srividya Desireddy <srividya.dr@samsung.com>, "sjenning@redhat.com" <sjenning@redhat.com>, "ddstreet@ieee.org" <ddstreet@ieee.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "penberg@kernel.org" <penberg@kernel.org>, Dinakar Reddy Pathireddy <dinakar.p@samsung.com>, SHARAN ALLUR <sharan.allur@samsung.com>, RAJIB BASU <rajib.basu@samsung.com>, JUHUN KIM <juhunkim@samsung.com>, "srividya.desireddy@gmail.com" <srividya.desireddy@gmail.com>

On Thu, Oct 19, 2017 at 12:31:18AM +0300, Timofey Titovets wrote:
> > +static void zswap_fill_page(void *ptr, unsigned long value)
> > +{
> > +       unsigned int pos;
> > +       unsigned long *page;
> > +
> > +       page = (unsigned long *)ptr;
> > +       if (value == 0)
> > +               memset(page, 0, PAGE_SIZE);
> > +       else {
> > +               for (pos = 0; pos < PAGE_SIZE / sizeof(*page); pos++)
> > +                       page[pos] = value;
> > +       }
> > +}
> 
> Same here, but with memcpy().

No.  Use memset_l which is optimised for this specific job.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
