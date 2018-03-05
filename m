Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5F6716B0008
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 14:05:59 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id d19so7675988pgn.20
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 11:05:59 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id z8-v6si9715053plo.762.2018.03.05.11.05.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 05 Mar 2018 11:05:58 -0800 (PST)
Date: Mon, 5 Mar 2018 11:05:50 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC, PATCH 00/22] Partial MKTME enabling
Message-ID: <20180305190549.GA10418@bombadil.infradead.org>
References: <20180305162610.37510-1-kirill.shutemov@linux.intel.com>
 <20180305183050.GA22743@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180305183050.GA22743@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Mar 05, 2018 at 10:30:50AM -0800, Christoph Hellwig wrote:
> On Mon, Mar 05, 2018 at 07:25:48PM +0300, Kirill A. Shutemov wrote:
> > Hi everybody,
> > 
> > Here's updated version of my patchset that brings support of MKTME.
> 
> It would really help if you'd explain what "MKTME" is..

You needed to keep reading, to below the -------------- line.

I agree though, that should have been up top.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
