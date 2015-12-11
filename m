Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id BF1F56B0253
	for <linux-mm@kvack.org>; Fri, 11 Dec 2015 17:20:17 -0500 (EST)
Received: by qgz52 with SMTP id 52so20842703qgz.1
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 14:20:17 -0800 (PST)
Received: from mail-qk0-x232.google.com (mail-qk0-x232.google.com. [2607:f8b0:400d:c09::232])
        by mx.google.com with ESMTPS id p104si22301267qgd.126.2015.12.11.14.20.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Dec 2015 14:20:17 -0800 (PST)
Received: by qkck189 with SMTP id k189so24925813qkc.0
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 14:20:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F39F82EEF@ORSMSX114.amr.corp.intel.com>
References: <cover.1449861203.git.tony.luck@intel.com>
	<23b2515da9d06b198044ad83ca0a15ba38c24e6e.1449861203.git.tony.luck@intel.com>
	<CALCETrU026BDNk=WZWrsgzpe0yT2Z=DK4Cn6mNYi6yBgsh-+nQ@mail.gmail.com>
	<3908561D78D1C84285E8C5FCA982C28F39F82D87@ORSMSX114.amr.corp.intel.com>
	<CALCETrVeALAHbiLytBO=2WAwifon=K-wB6mCCWBfuuUu7dbBVA@mail.gmail.com>
	<3908561D78D1C84285E8C5FCA982C28F39F82EEF@ORSMSX114.amr.corp.intel.com>
Date: Fri, 11 Dec 2015 14:20:16 -0800
Message-ID: <CAPcyv4hR+FNZ7b1duZ9g9e0xWnAwBsMtnzms_ZRvssXNJUaVoA@mail.gmail.com>
Subject: Re: [PATCHV2 3/3] x86, ras: Add mcsafe_memcpy() function to recover
 from machine checks
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>

On Fri, Dec 11, 2015 at 2:17 PM, Luck, Tony <tony.luck@intel.com> wrote:
>> Also, would it be more straightforward if the mcexception landing pad
>> looked up the va -> pa mapping by itself?  Or is that somehow not
>> reliable?
>
> If we did get all the above right, then we could have
> target use virt_to_phys() to convert to physical ...
> I don't see that this part would be a problem.

virt_to_phys() implies a linear address.  In the case of the use in
the pmem driver we'll be using an ioremap()'d address off somewherein
vmalloc space.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
