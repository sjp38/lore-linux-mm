Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 29DC36B038B
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 12:01:55 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id s186so103309888qkb.5
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 09:01:55 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y65si7344283qkd.195.2017.03.02.09.01.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Mar 2017 09:01:34 -0800 (PST)
Subject: Re: [RFC PATCH v4 19/28] swiotlb: Add warnings for use of bounce
 buffers with SME
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
 <20170216154619.19244.76653.stgit@tlendack-t1.amdoffice.net>
 <20170217155955.GK30272@char.us.ORACLE.com>
 <17c8099a-5495-5f1d-4c8a-bd9f5d2c5e58@amd.com>
From: Paolo Bonzini <pbonzini@redhat.com>
Message-ID: <ecc3f246-3626-3788-25f0-9178e38b92b1@redhat.com>
Date: Thu, 2 Mar 2017 18:01:26 +0100
MIME-Version: 1.0
In-Reply-To: <17c8099a-5495-5f1d-4c8a-bd9f5d2c5e58@amd.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Larry Woodman <lwoodman@redhat.com>, Dmitry Vyukov <dvyukov@google.com>



On 17/02/2017 17:51, Tom Lendacky wrote:
> 
> It's meant just to notify the user about the condition. The user could
> then decide to use an alternative device that supports a greater DMA
> range (I can probably change it to a dev_warn_once() so that a device
> is identified).  I would be nice if I could issue this message once per
> device that experienced this.  I didn't see anything that would do
> that, though.

dev_warn_once would print once only, not once per device.  But if you
leave the dev_warn elsewhere, this can be just pr_warn_once.

Paolo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
