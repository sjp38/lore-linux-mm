Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4DADF28073B
	for <linux-mm@kvack.org>; Fri, 19 May 2017 17:07:37 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id j66so92369369oib.2
        for <linux-mm@kvack.org>; Fri, 19 May 2017 14:07:37 -0700 (PDT)
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (mail-cys01nam02on0074.outbound.protection.outlook.com. [104.47.37.74])
        by mx.google.com with ESMTPS id o68si2944000oik.227.2017.05.19.14.07.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 19 May 2017 14:07:36 -0700 (PDT)
Subject: Re: [PATCH v5 28/32] x86/mm, kexec: Allow kexec to be used with SME
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
 <20170418212121.10190.94885.stgit@tlendack-t1.amdoffice.net>
 <20170517191755.h2xluopk2p6suw32@pd.tnic>
 <1b74e0e6-3dda-f638-461b-f73af9904360@amd.com>
 <20170519205836.3wvl3nztqyyouje3@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <5ef96f3a-6ebd-1d4d-7ac9-05dbed45d998@amd.com>
Date: Fri, 19 May 2017 16:07:24 -0500
MIME-Version: 1.0
In-Reply-To: <20170519205836.3wvl3nztqyyouje3@pd.tnic>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S.
 Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 5/19/2017 3:58 PM, Borislav Petkov wrote:
> On Fri, May 19, 2017 at 03:45:28PM -0500, Tom Lendacky wrote:
>> Actually there is.  The above will result in data in the cache because
>> halt() turns into a function call if CONFIG_PARAVIRT is defined (refer
>> to the comment above where do_wbinvd_halt is set to true). I could make
>> this a native_wbinvd() and native_halt()
>
> That's why we have the native_* versions - to bypass paravirt crap.

As long as those never change from static inline everything will be
fine. I can change it, but I really like how it explicitly indicates
what is needed in this case. Even if the function gets changed from
static inline the fact that the instructions are sequential in the
function covers that case.

Thanks,
Tom

>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
