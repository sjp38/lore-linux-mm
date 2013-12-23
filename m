Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f176.google.com (mail-ea0-f176.google.com [209.85.215.176])
	by kanga.kvack.org (Postfix) with ESMTP id 06F716B0031
	for <linux-mm@kvack.org>; Mon, 23 Dec 2013 15:26:26 -0500 (EST)
Received: by mail-ea0-f176.google.com with SMTP id h14so2522312eaj.35
        for <linux-mm@kvack.org>; Mon, 23 Dec 2013 12:26:26 -0800 (PST)
Received: from jenni1.inet.fi (mta-out.inet.fi. [195.156.147.13])
        by mx.google.com with ESMTP id p9si21845268eew.55.2013.12.23.12.26.26
        for <linux-mm@kvack.org>;
        Mon, 23 Dec 2013 12:26:26 -0800 (PST)
Date: Mon, 23 Dec 2013 20:54:33 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v4 21/22] Add support for pmd_faults
Message-ID: <20131223185433.GA18067@node.dhcp.inet.fi>
References: <cover.1387748521.git.matthew.r.wilcox@intel.com>
 <e944917f571781b46ca4dbb789ae8a86c5166059.1387748521.git.matthew.r.wilcox@intel.com>
 <20131223134113.GA14806@node.dhcp.inet.fi>
 <20131223145031.GB11091@parisc-linux.org>
 <20131223151003.GA15744@node.dhcp.inet.fi>
 <20131223184222.GE11091@parisc-linux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131223184222.GE11091@parisc-linux.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew@wil.cx>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>

On Mon, Dec 23, 2013 at 11:42:22AM -0700, Matthew Wilcox wrote:
> > Do you know anyone who relay on SIGBUS for correctness?
> 
> Oh, I remember the real reason now.  If we install a PMD that hangs off
> the end of the file then by reading past i_size, we can read the blocks of
> whatever happens to be in storage after the end of the file, which could
> be another file's data.  This doesn't happen for the PTE case because the
> existing code only works for filesystems with a block size == PAGE_SIZE.

I see. It's valid reason. Probably, it's better to add comment there.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
