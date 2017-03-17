Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8FA2D6B038A
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 07:10:27 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id r5so58600296qtb.1
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 04:10:27 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m62si6185528qkb.143.2017.03.17.04.09.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Mar 2017 04:09:58 -0700 (PDT)
Subject: Re: [RFC PATCH v2 29/32] kvm: svm: Add support for SEV DEBUG_DECRYPT
 command
References: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
 <148846789744.2349.167641684941925238.stgit@brijesh-build-machine>
 <4579cfdd-1797-8b47-8e00-254e3f6eb73f@redhat.com>
 <d89ef60d-a97c-b712-fb0f-0242ebebb91a@amd.com>
From: Paolo Bonzini <pbonzini@redhat.com>
Message-ID: <ca24bbc2-25cf-a5ca-cd39-5862036214bb@redhat.com>
Date: Fri, 17 Mar 2017 12:09:42 +0100
MIME-Version: 1.0
In-Reply-To: <d89ef60d-a97c-b712-fb0f-0242ebebb91a@amd.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brijesh Singh <brijesh.singh@amd.com>, simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, bp@suse.de, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, mst@redhat.com, linux-crypto@vger.kernel.org, tj@kernel.org, akpm@linux-foundation.org, davem@davemloft.net



On 16/03/2017 19:41, Brijesh Singh wrote:
>>
>> Please do add it, it doesn't seem very different from what you're doing
>> in LAUNCH_UPDATE_DATA.  There's no need for a separate
>> __sev_dbg_decrypt_page function, you can just pin/unpin here and do a
>> per-page loop as in LAUNCH_UPDATE_DATA.
> 
> I can certainly add support to handle crossing the page boundary cases.
> Should we limit the size to prevent user passing arbitrary long length
> and we end up looping inside the kernel? I was thinking to limit to a
> PAGE_SIZE.

I guess it depends on how it's used.  PAGE_SIZE makes sense since you
only know if a physical address is encrypted when you reach it from a
visit of the page tables.

Paolo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
