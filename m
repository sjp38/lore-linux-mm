Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f176.google.com (mail-yk0-f176.google.com [209.85.160.176])
	by kanga.kvack.org (Postfix) with ESMTP id 06DD76B0038
	for <linux-mm@kvack.org>; Mon,  9 Nov 2015 19:44:42 -0500 (EST)
Received: by ykek133 with SMTP id k133so293495439yke.2
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 16:44:41 -0800 (PST)
Received: from g4t3426.houston.hp.com (g4t3426.houston.hp.com. [15.201.208.54])
        by mx.google.com with ESMTPS id p82si365122ywe.224.2015.11.09.16.44.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Nov 2015 16:44:41 -0800 (PST)
Message-ID: <1447116034.21443.41.camel@hpe.com>
Subject: Re: [PATCH v4 RESEND 4/11] x86/asm: Fix pud/pmd interfaces to
 handle large PAT bit
From: Toshi Kani <toshi.kani@hpe.com>
Date: Mon, 09 Nov 2015 17:40:34 -0700
In-Reply-To: <1447111134.21443.30.camel@hpe.com>
References: <1442514264-12475-1-git-send-email-toshi.kani@hpe.com>
	 <1442514264-12475-5-git-send-email-toshi.kani@hpe.com>
	 <5640E08F.5020206@oracle.com> <1447096601.21443.15.camel@hpe.com>
	 <5640F673.8070400@oracle.com> <20151109204710.GB5443@node.shutemov.name>
	 <56411FFB.80104@oracle.com> <1447111134.21443.30.camel@hpe.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boris Ostrovsky <boris.ostrovsky@oracle.com>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, bp@alien8.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, jgross@suse.com, konrad.wilk@oracle.com, elliott@hpe.com

On Mon, 2015-11-09 at 16:18 -0700, Toshi Kani wrote:
> On Mon, 2015-11-09 at 17:36 -0500, Boris Ostrovsky wrote:
> > On 11/09/2015 03:47 PM, Kirill A. Shutemov wrote:
> > > On Mon, Nov 09, 2015 at 02:39:31PM -0500, Boris Ostrovsky wrote:
> > > > On 11/09/2015 02:16 PM, Toshi Kani wrote:
 :
> > > > 
> > > > FWIW, it looks like pmd_pfn_mask() inline is causing this. Reverting it
> > > > alone makes this crash go away.
> > > Could you check the patch below?
> > 
> > 
> > I does fix the problem on baremetal, thanks. My 32-bit Xen guests still 
> > fail which I thought was the same issue but now that I looked at it more 
> > carefully it has different signature.
> 
> I do not think Xen is hitting this, but I think page_level_mask() has the same
> issue for a long time.  I will set up 32-bit env on a system with >4GB memory 
> to verify this.

As Kirill explained me in his code review comment for *PAGE_MASK, page_level_mas
k() is fine as it is used for virtual addresses.

-Toshi  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
