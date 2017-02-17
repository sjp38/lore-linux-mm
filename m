Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 59E1F440608
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 10:56:33 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id y6so50744513pgy.5
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 07:56:33 -0800 (PST)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-by2nam01on0049.outbound.protection.outlook.com. [104.47.34.49])
        by mx.google.com with ESMTPS id u18si10662248plj.6.2017.02.17.07.56.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 17 Feb 2017 07:56:32 -0800 (PST)
Subject: Re: [RFC PATCH v4 02/28] x86: Set the write-protect cache mode for
 full PAT support
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
 <20170216154225.19244.96438.stgit@tlendack-t1.amdoffice.net>
 <20170217110724.ah5s3rz6emwxoc3u@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <389b298d-b73e-bd17-626b-974b3848232d@amd.com>
Date: Fri, 17 Feb 2017 09:56:17 -0600
MIME-Version: 1.0
In-Reply-To: <20170217110724.ah5s3rz6emwxoc3u@pd.tnic>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S.
 Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Larry Woodman <lwoodman@redhat.com>, Dmitry Vyukov <dvyukov@google.com>

On 2/17/2017 5:07 AM, Borislav Petkov wrote:
> On Thu, Feb 16, 2017 at 09:42:25AM -0600, Tom Lendacky wrote:
>> For processors that support PAT, set the write-protect cache mode
>> (_PAGE_CACHE_MODE_WP) entry to the actual write-protect value (x05).
>>
>> Acked-by: Borislav Petkov <bp@suse.de>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>
> Just a nit:
>
> Subject should have "x86/mm/pat: " prefix but that can be fixed when
> applying.

I'll go through the series and verify/fix the prefix for each patch.

Thanks,
Tom

>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
