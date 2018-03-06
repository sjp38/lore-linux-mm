Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id E17906B0009
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 03:36:58 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id n14so5286763wmc.0
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 00:36:58 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id p6sor8409831edh.18.2018.03.06.00.36.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Mar 2018 00:36:57 -0800 (PST)
Date: Tue, 6 Mar 2018 11:36:42 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC, PATCH 18/22] x86/mm: Handle allocation of encrypted pages
Message-ID: <20180306083642.yrhbcuz7fgwhmlix@node.shutemov.name>
References: <20180305162610.37510-1-kirill.shutemov@linux.intel.com>
 <20180305162610.37510-19-kirill.shutemov@linux.intel.com>
 <6551765a-5926-8445-d867-8f7c6bf343b4@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6551765a-5926-8445-d867-8f7c6bf343b4@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Mar 05, 2018 at 11:07:55AM -0800, Dave Hansen wrote:
> On 03/05/2018 08:26 AM, Kirill A. Shutemov wrote:
> > kmap_atomic_keyid() would map the page with the specified KeyID.
> > For now it's dummy implementation that would be replaced later.
> 
> I think you need to explain the tradeoffs here.  We could just change
> the linear map around, but you don't.  Why?

I don't think we settled on implementation by this point: kmap() is only
interface and doesn't imply what it acctually does. I *can* change linear
mapping if we would chose so.

I will explain the kmap() implementation in patches that would implement
it.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
