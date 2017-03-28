Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id D3D6C6B0390
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 07:40:51 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id r129so98962939pgr.18
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 04:40:51 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0126.outbound.protection.outlook.com. [104.47.0.126])
        by mx.google.com with ESMTPS id d23si3989948pgn.60.2017.03.28.04.40.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 28 Mar 2017 04:40:50 -0700 (PDT)
Subject: Re: [PATCHv3] x86/mm: set x32 syscall bit in SET_PERSONALITY()
References: <20170321174711.29880-1-dsafonov@virtuozzo.com>
 <alpine.DEB.2.20.1703212319440.3776@nanos>
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Message-ID: <cccc8f91-bd0d-fea0-b9b9-71653be38f61@virtuozzo.com>
Date: Tue, 28 Mar 2017 14:37:07 +0300
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1703212319440.3776@nanos>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, 0x7f454c46@gmail.com, Adam Borowski <kilobyte@angband.pl>, linux-mm@kvack.org, Andrei Vagin <avagin@gmail.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, "Kirill
 A. Shutemov" <kirill.shutemov@linux.intel.com>, x86@kernel.org, "H. Peter
 Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>

On 03/22/2017 01:21 AM, Thomas Gleixner wrote:
> On Tue, 21 Mar 2017, Dmitry Safonov wrote:
>> v3:
>> - clear x32 syscall flag during x32 -> x86-64 exec() (thanks, HPA).
>
> For correctness sake, this wants to be cleared in the IA32 path as
> well. It's not causing any harm, but ....
>
> I'll amend the patch.

So, just a gentle reminder about this problem.
Should I resend v4 with clearing x32 bit in ia32 path?
Or should I resend with this fixup:
https://lkml.org/lkml/2017/3/22/343

The fixup doesn't look as simple as clearing x32 syscall bit, but I may
be wrong.

-- 
              Dmitry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
