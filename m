Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 87F9B6B0397
	for <linux-mm@kvack.org>; Wed, 29 Mar 2017 13:08:53 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id v21so13474786pgo.22
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 10:08:53 -0700 (PDT)
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-sn1nam01on0042.outbound.protection.outlook.com. [104.47.32.42])
        by mx.google.com with ESMTPS id k2si5891799pfe.119.2017.03.29.10.08.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 29 Mar 2017 10:08:52 -0700 (PDT)
Subject: Re: [RFC PATCH v2 18/32] kvm: svm: Use the hardware provided GPA
 instead of page walk
References: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
 <148846776540.2349.3123530065053870721.stgit@brijesh-build-machine>
 <20170329151413.l2on26mdyyskwqlu@pd.tnic>
From: Brijesh Singh <brijesh.singh@amd.com>
Message-ID: <fc944319-ce21-7ba7-ffc3-9b0bb3c710b6@amd.com>
Date: Wed, 29 Mar 2017 12:08:38 -0500
MIME-Version: 1.0
In-Reply-To: <20170329151413.l2on26mdyyskwqlu@pd.tnic>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@suse.de>
Cc: brijesh.singh@amd.com, simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, mst@redhat.com, linux-crypto@vger.kernel.org, tj@kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

Hi Boris,

On 03/29/2017 10:14 AM, Borislav Petkov wrote:
> On Thu, Mar 02, 2017 at 10:16:05AM -0500, Brijesh Singh wrote:
>> From: Tom Lendacky <thomas.lendacky@amd.com>
>>
>> When a guest causes a NPF which requires emulation, KVM sometimes walks
>> the guest page tables to translate the GVA to a GPA. This is unnecessary
>> most of the time on AMD hardware since the hardware provides the GPA in
>> EXITINFO2.
>>
>> The only exception cases involve string operations involving rep or
>> operations that use two memory locations. With rep, the GPA will only be
>> the value of the initial NPF and with dual memory locations we won't know
>> which memory address was translated into EXITINFO2.
>>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> Reviewed-by: Borislav Petkov <bp@suse.de>
>
> I think I already asked you to remove Revewed-by tags when you have to
> change an already reviewed patch in non-trivial manner. Why does this
> one still have my Reviewed-by tag?
>

Actually this patch is included in RFCv2 series for the completeness.

The patch is already been reviewed and accepted in kvm upstream tree but it
was not present in the tip branch hence I cherry-picked into RFC so that we do
not break the build. SEV runtime behavior needs this patch. I have tried to
highlight it in cover letter. It was my bad that I missed fixing the Reviewed-by
tag during cherry picking. Sorry about that and will be extra careful next time around. Thanks


~ Brijesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
