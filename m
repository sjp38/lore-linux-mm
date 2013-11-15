Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 6C7696B0031
	for <linux-mm@kvack.org>; Fri, 15 Nov 2013 18:43:15 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id r10so1173424pdi.24
        for <linux-mm@kvack.org>; Fri, 15 Nov 2013 15:43:15 -0800 (PST)
Received: from psmtp.com ([74.125.245.184])
        by mx.google.com with SMTP id qj1si3279678pbc.144.2013.11.15.15.43.13
        for <linux-mm@kvack.org>;
        Fri, 15 Nov 2013 15:43:14 -0800 (PST)
Received: by mail-ie0-f175.google.com with SMTP id u16so5509202iet.6
        for <linux-mm@kvack.org>; Fri, 15 Nov 2013 15:43:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20131115225540.GA5485@anatevka.fc.hp.com>
References: <20131114180455.GA32212@anatevka.fc.hp.com>
	<CAOJsxLFWMi8DoFp+ufri7XoFO27v+2=0oksh8+NhM6P-OdkOwg@mail.gmail.com>
	<20131115005049.GJ5116@anatevka.fc.hp.com>
	<20131115062417.GB9237@gmail.com>
	<CAE9FiQWzSTtW8N=0hoUe6iCSM-k64Mv97n0whAS0_vZ+psuOsg@mail.gmail.com>
	<5285C639.5040203@zytor.com>
	<20131115140738.GB6637@redhat.com>
	<CAE9FiQUnw9Ujmdtq-AgC4VctQ=fZSBkzehoTbvw=aZeARL+pwA@mail.gmail.com>
	<20131115180324.GD6637@redhat.com>
	<CAE9FiQU_OstEq3VWwBB879O4EY0DE+zVWVens+w0MLFUQmr3sw@mail.gmail.com>
	<20131115225540.GA5485@anatevka.fc.hp.com>
Date: Fri, 15 Nov 2013 15:43:12 -0800
Message-ID: <CAE9FiQVOeDmdKMgnuV1kt6_aEbLG9aNKcRJqoL61pUzermMDbg@mail.gmail.com>
Subject: Re: [PATCH 0/3] Early use of boot service memory
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jerry.hoemann@hp.com
Cc: Vivek Goyal <vgoyal@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Pekka Enberg <penberg@kernel.org>, Rob Landley <rob@landley.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, x86 maintainers <x86@kernel.org>, Matt Fleming <matt.fleming@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "list@ebiederm.org:DOCUMENTATION" <linux-doc@vger.kernel.org>, "list@ebiederm.org:MEMORY MANAGEMENT" <linux-mm@kvack.org>, linux-efi@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Fri, Nov 15, 2013 at 2:55 PM,  <jerry.hoemann@hp.com> wrote:
>> You may need bunch of PCIe cards installed.
>>
>> The system with 6TiB + 16 PCIe cards, second kernel OOM.
>> The system with 4.5TiB + 16 PCIe cards, second kernel works with vmcore dumped.
>
> Yinghai,
>
> Your original email said you were using "legacy mode".  Does this mean
> you're not running makedumpfile in cyclic mode?  Cyclic mode makes
> a *big* difference in memory foot print of makedumpfile.

I mean: boot linux with legacy bios mode instead UEFI native boot.

Thanks

Yinghai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
