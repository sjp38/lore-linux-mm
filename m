Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id B92AF6B0038
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 05:16:06 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id c9so9218612wrb.4
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 02:16:06 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id i23sor7823188edj.9.2017.12.18.02.16.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Dec 2017 02:16:05 -0800 (PST)
Date: Mon, 18 Dec 2017 13:16:03 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 0/3] x86/mm/encrypt: Simplify pgtable helpers
Message-ID: <20171218101603.eyqouuifs6vyvcak@node.shutemov.name>
References: <20171212114544.56680-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171212114544.56680-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Borislav Petkov <bp@suse.de>, Brijesh Singh <brijesh.singh@amd.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Dec 12, 2017 at 02:45:41PM +0300, Kirill A. Shutemov wrote:
> This patchset simplifies sme_populate_pgd(), sme_populate_pgd_large() and
> sme_pgtable_calc() functions.
> 
> As a side effect, the patchset makes encryption code ready to boot-time
> switching between paging modes.
> 
> The patchset is build on top of Tom's "x86: SME: BSP/SME microcode update
> fix" patchset.
> 
> It was only build-tested. Tom, could you please get it tested properly?

Tom, do you have time to take a look?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
