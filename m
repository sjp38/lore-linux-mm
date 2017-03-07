Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1D2496B0389
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 12:43:01 -0500 (EST)
Received: by mail-lf0-f71.google.com with SMTP id h89so5817187lfi.6
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 09:43:01 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTP id n36si267325lfi.293.2017.03.07.09.42.59
        for <linux-mm@kvack.org>;
        Tue, 07 Mar 2017 09:42:59 -0800 (PST)
Date: Tue, 7 Mar 2017 18:42:51 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [RFC PATCH v4 28/28] x86: Add support to make use of Secure
 Memory Encryption
Message-ID: <20170307174251.qrg4kgi34anuxd33@pd.tnic>
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
 <20170216154825.19244.32545.stgit@tlendack-t1.amdoffice.net>
 <20170301184055.gl3iic3gir6zzb23@pd.tnic>
 <7e6c308f-3caf-5531-3cb2-9b6986f4288e@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <7e6c308f-3caf-5531-3cb2-9b6986f4288e@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Larry Woodman <lwoodman@redhat.com>, Dmitry Vyukov <dvyukov@google.com>

On Tue, Mar 07, 2017 at 10:05:00AM -0600, Tom Lendacky wrote:
> I can do that.  Because phys_base hasn't been updated yet, I'll have to
> create "on" and "off" constants and get their address in a similar way
> to the command line option so that I can do the strncmp properly.

Actually, wouldn't it be simpler to inspect the passed in buffer for
containing the chars 'o', 'n' - in that order, or 'o', 'f', 'f' - in
that order too? Because __cmdline_find_option() does copy the option
characters into the buffer.

Then you wouldn't need those "on" and "off" constants...

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
