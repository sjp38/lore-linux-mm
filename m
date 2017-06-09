Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 45E766B02B4
	for <linux-mm@kvack.org>; Fri,  9 Jun 2017 14:54:28 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id v104so9728110wrb.6
        for <linux-mm@kvack.org>; Fri, 09 Jun 2017 11:54:28 -0700 (PDT)
Received: from SMTP.EU.CITRIX.COM (smtp.eu.citrix.com. [185.25.65.24])
        by mx.google.com with ESMTPS id g25si1836197edg.140.2017.06.09.11.54.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Jun 2017 11:54:27 -0700 (PDT)
Subject: Re: [Xen-devel] [PATCH v6 10/34] x86, x86/mm, x86/xen, olpc: Use
 __va() against just the physical address in cr3
References: <20170607191309.28645.15241.stgit@tlendack-t1.amdoffice.net>
 <20170607191453.28645.92256.stgit@tlendack-t1.amdoffice.net>
 <b15e8924-4069-b5fa-adb2-86c164b1dd36@oracle.com>
 <4a7376fb-abfc-8edd-42b7-38de461ac65e@amd.com>
 <67fe69ac-a213-8de3-db28-0e54bba95127@oracle.com>
 <fcb196c8-f1eb-a38c-336c-7bd3929b029e@amd.com>
 <12c7e511-996d-cf60-3a3b-0be7b41bd85b@oracle.com>
 <d37917b1-8e49-e8a8-b9ac-59491331640f@citrix.com>
 <9725c503-2e33-2365-87f5-f017e1cbe9b6@amd.com>
 <8e8eac45-95be-f1b5-6f44-f131d275f7bc@oracle.com>
From: Andrew Cooper <andrew.cooper3@citrix.com>
Message-ID: <2d507507-8736-89ff-0579-c2eee4b3ac34@citrix.com>
Date: Fri, 9 Jun 2017 19:54:04 +0100
MIME-Version: 1.0
In-Reply-To: <8e8eac45-95be-f1b5-6f44-f131d275f7bc@oracle.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boris Ostrovsky <boris.ostrovsky@oracle.com>, Tom Lendacky <thomas.lendacky@amd.com>, linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Brijesh Singh <brijesh.singh@amd.com>, Toshimitsu Kani <toshi.kani@hpe.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Matt Fleming <matt@codeblueprint.co.uk>, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Larry Woodman <lwoodman@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, "Michael S. Tsirkin" <mst@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dave Young <dyoung@redhat.com>, Rik van Riel <riel@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>, Juergen Gross <jgross@suse.com>, xen-devel <xen-devel@lists.xen.org>, Paolo Bonzini <pbonzini@redhat.com>

On 09/06/17 19:43, Boris Ostrovsky wrote:
> On 06/09/2017 02:36 PM, Tom Lendacky wrote:
>>> basis, although (as far as I am aware) Xen as a whole would be able to
>>> encompass itself and all of its PV guests inside one single SME
>>> instance.
>> Yes, that is correct.

Thinking more about this, it would only be possible if all the PV guests
were SME-aware and understood not to choke when it finds a frame with a
high address bit set.

I expect the only viable way to implement this (should we wish) is to
have PV guests explicitly signal support (probably via an ELF note),
after which it needs to know about the existence of SME, the meaning of
the encrypted bit in PTEs, and to defer all configuration responsibility
to Xen.

~Andrew

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
