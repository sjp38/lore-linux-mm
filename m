Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id AC9196B025E
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 10:03:33 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id f132so1262906wmf.6
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 07:03:33 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id r13si11685538wrc.91.2017.12.19.07.03.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Dec 2017 07:03:32 -0800 (PST)
Date: Tue, 19 Dec 2017 16:03:32 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 14/17] memremap: simplify duplicate region handling in
	devm_memremap_pages
Message-ID: <20171219150332.GB13124@lst.de>
References: <20171215140947.26075-1-hch@lst.de> <20171215140947.26075-15-hch@lst.de> <CAPcyv4i2naLJjWzm+q0ORRfyHkT0f5dFBFKutuaXE3OgPcHX5g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAPcyv4i2naLJjWzm+q0ORRfyHkT0f5dFBFKutuaXE3OgPcHX5g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@lst.de>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, X86 ML <x86@kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Sun, Dec 17, 2017 at 09:34:11AM -0800, Dan Williams wrote:
> This is not racy, we'll catch the error on insert, and I think the
> extra debug information is useful for debugging a broken memory map or
> alignment math.

We can check for -D?EXIST and print the warning, but it's a weird pattern
for sure.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
