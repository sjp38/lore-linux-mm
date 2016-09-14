Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8356E6B0253
	for <linux-mm@kvack.org>; Wed, 14 Sep 2016 10:12:40 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id r126so49875472oib.0
        for <linux-mm@kvack.org>; Wed, 14 Sep 2016 07:12:40 -0700 (PDT)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0076.outbound.protection.outlook.com. [104.47.38.76])
        by mx.google.com with ESMTPS id h34si18819183otb.232.2016.09.14.07.12.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 14 Sep 2016 07:12:24 -0700 (PDT)
Subject: Re: [RFC PATCH v2 16/20] x86: Check for memory encryption on the APs
References: <20160822223529.29880.50884.stgit@tlendack-t1.amdoffice.net>
 <20160822223829.29880.10341.stgit@tlendack-t1.amdoffice.net>
 <20160912164303.kaqx2ayqjtbkcc2z@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <d4ba2c6c-491a-7107-9a0d-daa78446cd9c@amd.com>
Date: Wed, 14 Sep 2016 09:12:17 -0500
MIME-Version: 1.0
In-Reply-To: <20160912164303.kaqx2ayqjtbkcc2z@pd.tnic>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Paolo Bonzini <pbonzini@redhat.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>



On 09/12/2016 11:43 AM, Borislav Petkov wrote:
> On Mon, Aug 22, 2016 at 05:38:29PM -0500, Tom Lendacky wrote:
>> Add support to check if memory encryption is active in the kernel and that
>> it has been enabled on the AP. If memory encryption is active in the kernel
> 
> A small nit: let's write out "AP" the first time at least: "... on the
> Application Processors (AP)." for more clarity.

Will do.

Thanks,
Tom

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
