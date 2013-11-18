Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 43A2E6B0035
	for <linux-mm@kvack.org>; Mon, 18 Nov 2013 14:34:07 -0500 (EST)
Received: by mail-pb0-f51.google.com with SMTP id up15so2444184pbc.24
        for <linux-mm@kvack.org>; Mon, 18 Nov 2013 11:34:06 -0800 (PST)
Received: from psmtp.com ([74.125.245.200])
        by mx.google.com with SMTP id sn7si10405008pab.167.2013.11.18.11.34.05
        for <linux-mm@kvack.org>;
        Mon, 18 Nov 2013 11:34:06 -0800 (PST)
Received: by mail-ie0-f170.google.com with SMTP id qd12so190294ieb.1
        for <linux-mm@kvack.org>; Mon, 18 Nov 2013 11:34:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20131118153211.GB32168@redhat.com>
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
	<20131118153211.GB32168@redhat.com>
Date: Mon, 18 Nov 2013 11:34:04 -0800
Message-ID: <CAE9FiQWue3rBVTmXAMoBpWCTgFQ1VP+bkm-k_v1wx4U94ctPBA@mail.gmail.com>
Subject: Re: [PATCH 0/3] Early use of boot service memory
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, jerry.hoemann@hp.com, Pekka Enberg <penberg@kernel.org>, Rob Landley <rob@landley.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, x86 maintainers <x86@kernel.org>, Matt Fleming <matt.fleming@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "list@ebiederm.org:DOCUMENTATION" <linux-doc@vger.kernel.org>, "list@ebiederm.org:MEMORY MANAGEMENT" <linux-mm@kvack.org>, linux-efi@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Mon, Nov 18, 2013 at 7:32 AM, Vivek Goyal <vgoyal@redhat.com> wrote:
>> You may need bunch of PCIe cards installed.
>>
>> The system with 6TiB + 16 PCIe cards, second kernel OOM.
>> The system with 4.5TiB + 16 PCIe cards, second kernel works with vmcore dumped.
>
> What's the distro you are testing with? Do you have latest bits of
> makeudmpfile where we use cyclic mode by default and one does not need
> more reserved memory because of more physical memory present in the
> box. I suspect that might be the problem in your testing environment
> and old makedumpfile wil try to allocate larger memory on large
> RAM machines and OOM.

Default RHEL 6.4.

Will check if i can enable cyclic mode.

Thanks

Yinghai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
