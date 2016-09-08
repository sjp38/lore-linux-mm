Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id D043183090
	for <linux-mm@kvack.org>; Thu,  8 Sep 2016 09:26:41 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ez1so101792956pab.1
        for <linux-mm@kvack.org>; Thu, 08 Sep 2016 06:26:41 -0700 (PDT)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-dm3nam03on0077.outbound.protection.outlook.com. [104.47.41.77])
        by mx.google.com with ESMTPS id h80si29150521pfk.107.2016.09.08.06.26.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 08 Sep 2016 06:26:40 -0700 (PDT)
Subject: Re: [RFC PATCH v2 07/20] x86: Provide general kernel support for
 memory encryption
References: <20160822223529.29880.50884.stgit@tlendack-t1.amdoffice.net>
 <20160822223646.29880.28794.stgit@tlendack-t1.amdoffice.net>
 <20160906093113.GA18319@pd.tnic>
 <f4125cae-63af-f8c7-086f-e297ce480a07@amd.com>
 <20160907155535.i7wh46uxxa2bj3ik@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <bc8f22db-b6f9-951f-145c-fed919098cbe@amd.com>
Date: Thu, 8 Sep 2016 08:26:27 -0500
MIME-Version: 1.0
In-Reply-To: <20160907155535.i7wh46uxxa2bj3ik@pd.tnic>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Paolo Bonzini <pbonzini@redhat.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 09/07/2016 10:55 AM, Borislav Petkov wrote:
> On Wed, Sep 07, 2016 at 09:30:54AM -0500, Tom Lendacky wrote:
>> _PAGE_ENC is #defined as sme_me_mask and sme_me_mask has already been
>> set (or not set) at this point - so it will be the mask if SME is
>> active or 0 if SME is not active.
> 
> Yeah, I remember :-)
> 
>> sme_early_init() is merely propagating the mask to other structures.
>> Since early_pmd_flags is mainly used in this file (one line in
>> head_64.S is the other place) I felt it best to modify it here. But it
>> can always be moved if you feel that is best.
> 
> Hmm, so would it work then if you stick it in early_pmd_flags'
> definition like you do with the other masks? I.e.,
> 
> pmdval_t early_pmd_flags = __PAGE_KERNEL_LARGE | _PAGE_ENC & ~(_PAGE_GLOBAL | _PAGE_NX);

When does this value get initialized?  Since _PAGE_ENC is #defined to
sme_me_mask, which is not set until the boot process begins, I'm afraid
we'd end up using the initial value of sme_me_mask, which is zero.  Do
I have that right?

Thanks,
Tom

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
