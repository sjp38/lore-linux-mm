Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id E0C6A6B0031
	for <linux-mm@kvack.org>; Mon, 18 Nov 2013 22:02:32 -0500 (EST)
Received: by mail-pb0-f42.google.com with SMTP id uo5so7699933pbc.29
        for <linux-mm@kvack.org>; Mon, 18 Nov 2013 19:02:32 -0800 (PST)
Received: from psmtp.com ([74.125.245.155])
        by mx.google.com with SMTP id yg5si10994833pbc.86.2013.11.18.19.02.30
        for <linux-mm@kvack.org>;
        Mon, 18 Nov 2013 19:02:31 -0800 (PST)
Received: by mail-ie0-f181.google.com with SMTP id e14so3503172iej.12
        for <linux-mm@kvack.org>; Mon, 18 Nov 2013 19:02:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <528ABFA3.6060905@zytor.com>
References: <CAOJsxLFkHQ6_f+=CMwfNLykh59TZH5VrWeVEDPCWPF1wiw7tjQ@mail.gmail.com>
	<20131114180455.GA32212@anatevka.fc.hp.com>
	<CAOJsxLFWMi8DoFp+ufri7XoFO27v+2=0oksh8+NhM6P-OdkOwg@mail.gmail.com>
	<20131115005049.GJ5116@anatevka.fc.hp.com>
	<20131115062417.GB9237@gmail.com>
	<CAE9FiQWzSTtW8N=0hoUe6iCSM-k64Mv97n0whAS0_vZ+psuOsg@mail.gmail.com>
	<5285C639.5040203@zytor.com>
	<20131115140738.GB6637@redhat.com>
	<CAE9FiQUnw9Ujmdtq-AgC4VctQ=fZSBkzehoTbvw=aZeARL+pwA@mail.gmail.com>
	<52865CA1.5020309@zytor.com>
	<20131115183002.GE6637@redhat.com>
	<528ABFA3.6060905@zytor.com>
Date: Mon, 18 Nov 2013 19:02:29 -0800
Message-ID: <CAE9FiQW+kbq5Eu-ivu897ogQUGjwKy6jYO9hnxbKyuWqoaQgJQ@mail.gmail.com>
Subject: Re: [PATCH 0/3] Early use of boot service memory
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Vivek Goyal <vgoyal@redhat.com>, Ingo Molnar <mingo@kernel.org>, jerry.hoemann@hp.com, Pekka Enberg <penberg@kernel.org>, Rob Landley <rob@landley.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, x86 maintainers <x86@kernel.org>, Matt Fleming <matt.fleming@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "list@ebiederm.org:DOCUMENTATION" <linux-doc@vger.kernel.org>, "list@ebiederm.org:MEMORY MANAGEMENT" <linux-mm@kvack.org>, linux-efi@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Mon, Nov 18, 2013 at 5:32 PM, H. Peter Anvin <hpa@zytor.com> wrote:
> On 11/15/2013 10:30 AM, Vivek Goyal wrote:
>>
>> And IOMMU support is very flaky with kdump. And IOMMU's can be turned
>> off at command line. And that would force one to remove crahkernel_low=0.
>> So change of one command line option forces change of another. It is
>> complicated.
>>
>> Also there are very few systems which work with IOMMU on. A lot more
>> which work without IOMMU. We have all these DMAR issues and still nobody
>> has been able to address IOMMU issues properly.
>>
>
> Why do we need such a big bounce buffer for kdump swiotlb anyway?
> Surely the vast majority of all dump devices don't need it, so it is
> there for completeness, no?

Yes, because normal path will need that 64M+32k default.

We may reduce that amount to 16M or 18M and in second kernel let
allocate less for swiotlb.

Thanks

Yinghai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
