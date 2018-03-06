Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 301E56B0007
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 03:18:24 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id o23so12834603wrc.9
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 00:18:24 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 24sor7681540edv.48.2018.03.06.00.18.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Mar 2018 00:18:23 -0800 (PST)
Date: Tue, 6 Mar 2018 11:18:07 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC, PATCH 13/22] mm, rmap: Free encrypted pages once mapcount
 drops to zero
Message-ID: <20180306081807.f3ohd7fg6jpohg4h@node.shutemov.name>
References: <20180305162610.37510-1-kirill.shutemov@linux.intel.com>
 <20180305162610.37510-14-kirill.shutemov@linux.intel.com>
 <eb2cc1cf-1be1-4535-f71b-fa33272a6f71@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <eb2cc1cf-1be1-4535-f71b-fa33272a6f71@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Mar 05, 2018 at 11:12:15AM -0800, Dave Hansen wrote:
> On 03/05/2018 08:26 AM, Kirill A. Shutemov wrote:
> >  extern void prep_encrypt_page(struct page *page, gfp_t gfp, unsigned int order);
> > +extern void free_encrypt_page(struct page *page, int keyid, unsigned int order);
> 
> The grammar here is weird, I think.
> 
> Why not free_encrypted_page()?

Okay, I'll fix this.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
