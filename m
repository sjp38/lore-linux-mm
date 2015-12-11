Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id CB8A16B0253
	for <linux-mm@kvack.org>; Fri, 11 Dec 2015 17:38:33 -0500 (EST)
Received: by obc18 with SMTP id 18so93097490obc.2
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 14:38:33 -0800 (PST)
Received: from mail-oi0-x236.google.com (mail-oi0-x236.google.com. [2607:f8b0:4003:c06::236])
        by mx.google.com with ESMTPS id u132si2774013oif.139.2015.12.11.14.38.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Dec 2015 14:38:33 -0800 (PST)
Received: by oiww189 with SMTP id w189so70700695oiw.3
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 14:38:33 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F39F82F97@ORSMSX114.amr.corp.intel.com>
References: <cover.1449861203.git.tony.luck@intel.com> <23b2515da9d06b198044ad83ca0a15ba38c24e6e.1449861203.git.tony.luck@intel.com>
 <CALCETrU026BDNk=WZWrsgzpe0yT2Z=DK4Cn6mNYi6yBgsh-+nQ@mail.gmail.com>
 <3908561D78D1C84285E8C5FCA982C28F39F82D87@ORSMSX114.amr.corp.intel.com>
 <CALCETrVeALAHbiLytBO=2WAwifon=K-wB6mCCWBfuuUu7dbBVA@mail.gmail.com>
 <3908561D78D1C84285E8C5FCA982C28F39F82EEF@ORSMSX114.amr.corp.intel.com>
 <CAPcyv4hR+FNZ7b1duZ9g9e0xWnAwBsMtnzms_ZRvssXNJUaVoA@mail.gmail.com>
 <CALCETrVcj=4sDaEXGNtYuq0kXLm7K9de1catqWPi25ae56g8Jg@mail.gmail.com> <3908561D78D1C84285E8C5FCA982C28F39F82F97@ORSMSX114.amr.corp.intel.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Fri, 11 Dec 2015 14:38:13 -0800
Message-ID: <CALCETrUK1raRagO=JxCRpy0_eKfS56gce737fVe9rtJqNwH+_A@mail.gmail.com>
Subject: Re: [PATCHV2 3/3] x86, ras: Add mcsafe_memcpy() function to recover
 from machine checks
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: "Williams, Dan J" <dan.j.williams@intel.com>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>

On Fri, Dec 11, 2015 at 2:35 PM, Luck, Tony <tony.luck@intel.com> wrote:
>> Also, are there really PCOMMIT-capable CPUs that still forcibly
>> broadcast MCE?  If, so, that's unfortunate.
>
> PCOMMIT and LMCE arrive together ... though BIOS is in the decision
> path to enable LMCE, so it is possible that some systems could still
> broadcast if the BIOS writer decides to not allow local.

I really wish Intel would stop doing that.

>
> But a machine check safe copy_from_user() would be useful
> current generation cpus that broadcast all the time.

Fair enough.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
