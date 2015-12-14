Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 1340B6B0038
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 03:36:30 -0500 (EST)
Received: by wmnn186 with SMTP id n186so110040892wmn.0
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 00:36:29 -0800 (PST)
Received: from mail-wm0-x229.google.com (mail-wm0-x229.google.com. [2a00:1450:400c:c09::229])
        by mx.google.com with ESMTPS id x9si44449502wje.220.2015.12.14.00.36.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Dec 2015 00:36:28 -0800 (PST)
Received: by mail-wm0-x229.google.com with SMTP id n186so34247723wmn.0
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 00:36:28 -0800 (PST)
Date: Mon, 14 Dec 2015 09:36:25 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCHV2 3/3] x86, ras: Add mcsafe_memcpy() function to recover
 from machine checks
Message-ID: <20151214083625.GA28073@gmail.com>
References: <CALCETrU026BDNk=WZWrsgzpe0yT2Z=DK4Cn6mNYi6yBgsh-+nQ@mail.gmail.com>
 <3908561D78D1C84285E8C5FCA982C28F39F82D87@ORSMSX114.amr.corp.intel.com>
 <CALCETrVeALAHbiLytBO=2WAwifon=K-wB6mCCWBfuuUu7dbBVA@mail.gmail.com>
 <3908561D78D1C84285E8C5FCA982C28F39F82EEF@ORSMSX114.amr.corp.intel.com>
 <CAPcyv4hR+FNZ7b1duZ9g9e0xWnAwBsMtnzms_ZRvssXNJUaVoA@mail.gmail.com>
 <CALCETrVcj=4sDaEXGNtYuq0kXLm7K9de1catqWPi25ae56g8Jg@mail.gmail.com>
 <3908561D78D1C84285E8C5FCA982C28F39F82F97@ORSMSX114.amr.corp.intel.com>
 <CALCETrUK1raRagO=JxCRpy0_eKfS56gce737fVe9rtJqNwH+_A@mail.gmail.com>
 <3908561D78D1C84285E8C5FCA982C28F39F82FED@ORSMSX114.amr.corp.intel.com>
 <CALCETrUFQXPB9HM8O+4UfMij7nodfrWtjicy0XNhOiWCka+4yw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrUFQXPB9HM8O+4UfMij7nodfrWtjicy0XNhOiWCka+4yw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "Luck, Tony" <tony.luck@intel.com>, "Williams, Dan J" <dan.j.williams@intel.com>, Borislav Petkov <bp@alien8.de>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>


* Andy Lutomirski <luto@amacapital.net> wrote:

> I still think it would be better if you get rid of BIT(63) and use a
> pair of landing pads, though.  They could be as simple as:
> 
> .Lpage_fault_goes_here:
>     xorq %rax, %rax
>     jmp .Lbad
> 
> .Lmce_goes_here:
>     /* set high bit of rax or whatever */
>     /* fall through */
> 
> .Lbad:
>     /* deal with it */
> 
> That way the magic is isolated to the function that needs the magic.

Seconded - this is the usual pattern we use in all assembly functions.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
