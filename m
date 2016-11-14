Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f197.google.com (mail-yb0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2FD6C6B0260
	for <linux-mm@kvack.org>; Mon, 14 Nov 2016 11:49:05 -0500 (EST)
Received: by mail-yb0-f197.google.com with SMTP id 206so133778134ybz.7
        for <linux-mm@kvack.org>; Mon, 14 Nov 2016 08:49:05 -0800 (PST)
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (mail-cys01nam02on0041.outbound.protection.outlook.com. [104.47.37.41])
        by mx.google.com with ESMTPS id t6si10399043oif.82.2016.11.14.08.49.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 14 Nov 2016 08:49:03 -0800 (PST)
Subject: Re: [RFC PATCH v3 14/20] iommu/amd: Disable AMD IOMMU if memory
 encryption is active
References: <20161110003426.3280.2999.stgit@tlendack-t1.amdoffice.net>
 <20161110003731.3280.67205.stgit@tlendack-t1.amdoffice.net>
 <20161114163204.GA2078@8bytes.org>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <b4403b85-42dd-66b2-bde6-726c6ac5ae0e@amd.com>
Date: Mon, 14 Nov 2016 10:48:52 -0600
MIME-Version: 1.0
In-Reply-To: <20161114163204.GA2078@8bytes.org>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 11/14/2016 10:32 AM, Joerg Roedel wrote:
> On Wed, Nov 09, 2016 at 06:37:32PM -0600, Tom Lendacky wrote:
>> +	/* For now, disable the IOMMU if SME is active */
>> +	if (sme_me_mask)
>> +		return -ENODEV;
>> +
> 
> Please print a message here telling the user why the IOMMU got disabled.

Will do.

Thanks,
Tom

> 
> 
> Thanks,
> 
> 	Joerg
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
