Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5E3206B0006
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 09:09:50 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id j28so13152973wrd.17
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 06:09:50 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q5sor1945922edj.54.2018.03.06.06.09.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Mar 2018 06:09:48 -0800 (PST)
Date: Tue, 6 Mar 2018 17:09:32 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC, PATCH 19/22] x86/mm: Implement free_encrypt_page()
Message-ID: <20180306140932.bdll5vh6qzyydqg4@node.shutemov.name>
References: <20180305162610.37510-1-kirill.shutemov@linux.intel.com>
 <20180305162610.37510-20-kirill.shutemov@linux.intel.com>
 <a692b2ff-b590-b731-ad14-18238f471a1c@intel.com>
 <20180306085412.vkgheeya24dze53t@node.shutemov.name>
 <64d11e65-76b7-4e70-553c-009263b50a1c@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <64d11e65-76b7-4e70-553c-009263b50a1c@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Mar 06, 2018 at 05:52:44AM -0800, Dave Hansen wrote:
> On 03/06/2018 12:54 AM, Kirill A. Shutemov wrote:
> >> Have you measured how slow this is?
> > No, I have not.
> 
> It would be handy to do this.  I *think* you can do it on normal
> hardware, even if it does not have "real" support for memory encryption.
>  Just don't set the encryption bits in the PTEs but go through all the
> motions of cache flushing.

Yes, allocation/freeing and KeyID interfaces can be tested with MKTME
support in hardware. I did most of my testing this way.

> I think that will help tell us whether this is a really specialized
> thing a la hugetlbfs or whether it's something we really want to support
> as a first-class citizen in the VM.

I will benchmark this. But not right now.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
