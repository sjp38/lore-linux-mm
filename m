Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 16EC682F99
	for <linux-mm@kvack.org>; Thu, 24 Dec 2015 08:37:20 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id l126so184942547wml.1
        for <linux-mm@kvack.org>; Thu, 24 Dec 2015 05:37:20 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id e2si18653396wmi.26.2015.12.24.05.37.18
        for <linux-mm@kvack.org>;
        Thu, 24 Dec 2015 05:37:18 -0800 (PST)
Date: Thu, 24 Dec 2015 14:37:13 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCHV3 3/3] x86, ras: Add mcsafe_memcpy() function to recover
 from machine checks
Message-ID: <20151224133713.GC4128@pd.tnic>
References: <cover.1450283985.git.tony.luck@intel.com>
 <d560d03663b6fd7a5bbeae9842934f329a7dcbdf.1450283985.git.tony.luck@intel.com>
 <20151222111349.GB3728@pd.tnic>
 <CA+8MBbJ+T0Bkea48rivWEZRn8_iPiSvrPm5p22RfbS7V0_KyEA@mail.gmail.com>
 <20151223125853.GF30213@pd.tnic>
 <CAPcyv4gXDHGgiqfve_fP1RLXBGfyWarjWgUU3QPMhnFn_BbshA@mail.gmail.com>
 <CA+8MBbJX+3SW7CxqWT1ghzzbdV9pgVxXNejg4XC1=sDFY3Xgpw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CA+8MBbJX+3SW7CxqWT1ghzzbdV9pgVxXNejg4XC1=sDFY3Xgpw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@gmail.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Elliott@pd.tnic, Robert <elliott@hpe.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86-ML <x86@kernel.org>

On Wed, Dec 23, 2015 at 12:46:20PM -0800, Tony Luck wrote:
> > I know, memcpy returns the ptr to @dest like a parrot
> 
> Maybe I need to change the name to remove the
> "memcpy" substring to avoid this confusion. How
> about "mcsafe_copy()"? Perhaps with a "__" prefix
> to point out it is a building block that will get various
> wrappers around it??
> 
> Dan wants a copy_from_nvdimm() that either completes
> the copy, or indicates where a machine check occurred.
> 
> I'm going to want a copy_from_user() that has two fault
> options (user gave a bad address -> -EFAULT, or the
> source address had an uncorrected error -> SIGBUS).

Sounds like standard kernel design to me. :)

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
