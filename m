Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 37AF96B0006
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 03:58:30 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id r15so12807750wrr.16
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 00:58:30 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id s13sor3584368edc.28.2018.03.06.00.58.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Mar 2018 00:58:29 -0800 (PST)
Date: Tue, 6 Mar 2018 11:58:13 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC, PATCH 00/22] Partial MKTME enabling
Message-ID: <20180306085813.d22slphcsrtzrtaq@node.shutemov.name>
References: <20180305162610.37510-1-kirill.shutemov@linux.intel.com>
 <20180305183050.GA22743@infradead.org>
 <20180305190549.GA10418@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180305190549.GA10418@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Christoph Hellwig <hch@infradead.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Mar 05, 2018 at 11:05:50AM -0800, Matthew Wilcox wrote:
> On Mon, Mar 05, 2018 at 10:30:50AM -0800, Christoph Hellwig wrote:
> > On Mon, Mar 05, 2018 at 07:25:48PM +0300, Kirill A. Shutemov wrote:
> > > Hi everybody,
> > > 
> > > Here's updated version of my patchset that brings support of MKTME.
> > 
> > It would really help if you'd explain what "MKTME" is..
> 
> You needed to keep reading, to below the -------------- line.
> 
> I agree though, that should have been up top.

My bad. Will update it for future postings.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
