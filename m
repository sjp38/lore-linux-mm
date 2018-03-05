Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 54E346B0025
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 13:31:14 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id c83so10153705pfk.5
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 10:31:14 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c1si8604456pga.513.2018.03.05.10.31.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 05 Mar 2018 10:31:13 -0800 (PST)
Date: Mon, 5 Mar 2018 10:30:50 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC, PATCH 00/22] Partial MKTME enabling
Message-ID: <20180305183050.GA22743@infradead.org>
References: <20180305162610.37510-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180305162610.37510-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Mar 05, 2018 at 07:25:48PM +0300, Kirill A. Shutemov wrote:
> Hi everybody,
> 
> Here's updated version of my patchset that brings support of MKTME.

It would really help if you'd explain what "MKTME" is..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
