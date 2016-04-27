Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6F67A6B0261
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 11:32:05 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id 68so40871705lfq.2
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 08:32:05 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id r9si31381838wme.19.2016.04.27.08.32.03
        for <linux-mm@kvack.org>;
        Wed, 27 Apr 2016 08:32:04 -0700 (PDT)
Date: Wed, 27 Apr 2016 17:31:58 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [RFC PATCH v1 01/18] x86: Set the write-protect cache mode for
 AMD processors
Message-ID: <20160427153158.GJ21011@pd.tnic>
References: <20160426225553.13567.19459.stgit@tlendack-t1.amdoffice.net>
 <20160426225604.13567.55443.stgit@tlendack-t1.amdoffice.net>
 <CALCETrU9ozp1mBKG-P88cKRJRY5bifn2Ab__AZcn5b33n3j2cg@mail.gmail.com>
 <5720D066.7080409@amd.com>
 <CALCETrV+JzPZjrrqkhWSVfvKQt62Aq8NSW=ZvfdiAi8XKoLi8A@mail.gmail.com>
 <5720D546.6050105@amd.com>
 <CALCETrVcS-H9BtCevT4=Luo2sK0A3cbBs7Rs=RaBr2yzOzxp4w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CALCETrVcS-H9BtCevT4=Luo2sK0A3cbBs7Rs=RaBr2yzOzxp4w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Tom Lendacky <thomas.lendacky@amd.com>, linux-arch <linux-arch@vger.kernel.org>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, kvm list <kvm@vger.kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, iommu@lists.linux-foundation.org, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Wed, Apr 27, 2016 at 08:12:56AM -0700, Andy Lutomirski wrote:
> I think there are some errata

Isn't that addressed by the first branch of the if-test in pat_init():

        if ((c->x86_vendor == X86_VENDOR_INTEL) &&
            (((c->x86 == 0x6) && (c->x86_model <= 0xd)) ||
             ((c->x86 == 0xf) && (c->x86_model <= 0x6)))) {


-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
