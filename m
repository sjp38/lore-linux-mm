Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 79EB16B0038
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 03:09:15 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id v186so2561367wma.9
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 00:09:15 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d8sor9256160edk.17.2017.11.22.00.09.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 Nov 2017 00:09:14 -0800 (PST)
Date: Wed, 22 Nov 2017 11:09:11 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv2 0/4] x86: 5-level related changes into decompression
 code
Message-ID: <20171122080911.6zblki4uzp7dugm4@node.shutemov.name>
References: <20171110220645.59944-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171110220645.59944-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, Nov 11, 2017 at 01:06:41AM +0300, Kirill A. Shutemov wrote:
> Hi Ingo,
> 
> Here's updated changes that prepare the code to boot-time switching between
> paging modes and handle booting in 5-level mode when bootloader put kernel
> image above 4G, but haven't enabled 5-level paging for us.
> 
> I've updated patches based on your feedback.
> 
> Please review and consider applying.

Gentle ping.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
