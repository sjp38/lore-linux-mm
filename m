Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 489146B0069
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 10:49:20 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id d4so2375362pgv.4
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 07:49:20 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d6si1548662pfc.249.2017.11.29.07.49.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 29 Nov 2017 07:49:19 -0800 (PST)
Date: Wed, 29 Nov 2017 16:49:08 +0100
From: Borislav Petkov <bp@suse.de>
Subject: Re: [PATCHv2 0/4] x86: 5-level related changes into decompression
 code
Message-ID: <20171129154908.6y4st6xc7hbsey2v@pd.tnic>
References: <20171110220645.59944-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20171110220645.59944-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, Nov 11, 2017 at 01:06:41AM +0300, Kirill A. Shutemov wrote:
> Hi Ingo,
> 
> Here's updated changes that prepare the code to boot-time switching between
> paging modes and handle booting in 5-level mode when bootloader put kernel
> image above 4G, but haven't enabled 5-level paging for us.

Btw, if I enable CONFIG_X86_5LEVEL with 4.15-rc1 on an AMD box, the box
triple-faults and ends up spinning in a reboot loop. Even though it
should say:

early console in setup code
This kernel requires the following features not present on the CPU:
la57 
Unable to boot - please use a kernel appropriate for your CPU.

and halt.

A kvm guest still does that but baremetal triple-faults.

Ideas?

-- 
Regards/Gruss,
    Boris.

SUSE Linux GmbH, GF: Felix ImendA?rffer, Jane Smithard, Graham Norton, HRB 21284 (AG NA 1/4 rnberg)
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
