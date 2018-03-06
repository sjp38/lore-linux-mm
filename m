Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 65D836B0003
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 10:01:17 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id z14so13513649wrh.1
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 07:01:17 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u59sor8903742edc.53.2018.03.06.07.01.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Mar 2018 07:01:15 -0800 (PST)
Date: Tue, 6 Mar 2018 18:00:59 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC, PATCH 13/22] mm, rmap: Free encrypted pages once mapcount
 drops to zero
Message-ID: <20180306150059.fclktp7qdhy37vyz@node.shutemov.name>
References: <20180305162610.37510-1-kirill.shutemov@linux.intel.com>
 <20180305162610.37510-14-kirill.shutemov@linux.intel.com>
 <e04536bc-77e9-84d0-3c23-1dfea8542da5@intel.com>
 <20180306082743.2epdfxv4ds7hz7py@node.shutemov.name>
 <d1faf309-837b-d385-4d0a-c840fdab8b36@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d1faf309-837b-d385-4d0a-c840fdab8b36@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Mar 06, 2018 at 06:59:04AM -0800, Dave Hansen wrote:
> On 03/06/2018 12:27 AM, Kirill A. Shutemov wrote:
> > +	anon_vma = page_anon_vma(page);
> > +	if (anon_vma_encrypted(anon_vma)) {
> > +		int keyid = anon_vma_keyid(anon_vma);
> > +		free_encrypt_page(page, keyid, compound_order(page));
> > +	}
> >  }
> 
> So, just double-checking: free_encrypt_page() neither "frees and
> encrypts the page"" nor "free an encrypted page"?
> 
> That seems a bit suboptimal. :)

Yes, I'm bad with words :)

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
