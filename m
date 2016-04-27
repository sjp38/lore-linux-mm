Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id C30C86B0005
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 10:05:42 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id w143so40096497wmw.3
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 07:05:42 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id mb4si4571260wjb.202.2016.04.27.07.05.25
        for <linux-mm@kvack.org>;
        Wed, 27 Apr 2016 07:05:25 -0700 (PDT)
Date: Wed, 27 Apr 2016 16:05:20 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [RFC PATCH v1 00/18] x86: Secure Memory Encryption (AMD)
Message-ID: <20160427140520.GG21011@pd.tnic>
References: <20160426225553.13567.19459.stgit@tlendack-t1.amdoffice.net>
 <20160322130058.GA16528@xo-6d-61-c0.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20160322130058.GA16528@xo-6d-61-c0.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Tom Lendacky <thomas.lendacky@amd.com>, linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Tue, Mar 22, 2016 at 02:00:58PM +0100, Pavel Machek wrote:
> Why would I want SME on my system? My system seems to work without it.

Your system doesn't have it and SME is default off.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
