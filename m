Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id B8C5A6B025E
	for <linux-mm@kvack.org>; Mon, 14 Nov 2016 11:51:39 -0500 (EST)
Received: by mail-pa0-f71.google.com with SMTP id ro13so93684891pac.7
        for <linux-mm@kvack.org>; Mon, 14 Nov 2016 08:51:39 -0800 (PST)
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (mail-co1nam03on0089.outbound.protection.outlook.com. [104.47.40.89])
        by mx.google.com with ESMTPS id b62si22950626pfg.0.2016.11.14.08.51.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 14 Nov 2016 08:51:38 -0800 (PST)
Subject: Re: [RFC PATCH v3 02/20] x86: Set the write-protect cache mode for
 full PAT support
References: <20161110003426.3280.2999.stgit@tlendack-t1.amdoffice.net>
 <20161110003448.3280.27573.stgit@tlendack-t1.amdoffice.net>
 <20161110131400.bmeoojsrin2zi2w2@pd.tnic>
 <1478827480.20881.142.camel@hpe.com>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <01f705f1-484b-4407-7b7a-e8e69966581f@amd.com>
Date: Mon, 14 Nov 2016 10:51:27 -0600
MIME-Version: 1.0
In-Reply-To: <1478827480.20881.142.camel@hpe.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kani, Toshimitsu" <toshi.kani@hpe.com>, "bp@alien8.de" <bp@alien8.de>
Cc: "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "dvyukov@google.com" <dvyukov@google.com>, "corbet@lwn.net" <corbet@lwn.net>, "arnd@arndb.de" <arnd@arndb.de>, "matt@codeblueprint.co.uk" <matt@codeblueprint.co.uk>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "aryabinin@virtuozzo.com" <aryabinin@virtuozzo.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "konrad.wilk@oracle.com" <konrad.wilk@oracle.com>, "kasan-dev@googlegroups.com" <kasan-dev@googlegroups.com>, "x86@kernel.org" <x86@kernel.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "riel@redhat.com" <riel@redhat.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, "mingo@redhat.com" <mingo@redhat.com>, "joro@8bytes.org" <joro@8bytes.org>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "hpa@zytor.com" <hpa@zytor.com>, "luto@kernel.org" <luto@kernel.org>, "glider@google.com" <glider@google.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "rkrcmar@redhat.com" <rkrcmar@redhat.com>

On 11/10/2016 07:26 PM, Kani, Toshimitsu wrote:
> On Thu, 2016-11-10 at 14:14 +0100, Borislav Petkov wrote:
>> + Toshi.
>>
>> On Wed, Nov 09, 2016 at 06:34:48PM -0600, Tom Lendacky wrote:
>>>
>>> For processors that support PAT, set the write-protect cache mode
>>> (_PAGE_CACHE_MODE_WP) entry to the actual write-protect value
>>> (x05).
> 
> Using slot 6 may be more cautious (for the same reason slot 7 was used
> for WT), but I do not have a strong opinion for it.
> 
> set_page_memtype() cannot track the use of WP type since there is no
> extra-bit available for WP, but WP is only supported by
> early_memremap_xx() interfaces in this series.  So, I think we should
> just document that WP is only intended for temporary mappings at boot-
> time until this issue is resolved.  Also, we need to make sure that
> this early_memremap for WP is only called after pat_init() is done.

Sounds good, I'll add documentation to cover these points.

> 
> A nit - please add WP to the function header comment below.
> "This function initializes PAT MSR and PAT table with an OS-defined
> value to enable additional cache attributes, WC and WT."

Will do.

Thanks,
Tom

> 
> Thanks,
> -Toshi
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
