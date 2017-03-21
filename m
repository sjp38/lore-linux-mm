Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1658A6B03A8
	for <linux-mm@kvack.org>; Tue, 21 Mar 2017 15:38:40 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e126so71732796pfg.3
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 12:38:40 -0700 (PDT)
Received: from EUR03-DB5-obe.outbound.protection.outlook.com (mail-eopbgr40108.outbound.protection.outlook.com. [40.107.4.108])
        by mx.google.com with ESMTPS id v18si15894915pfl.7.2017.03.21.12.38.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 21 Mar 2017 12:38:39 -0700 (PDT)
Subject: Re: [PATCHv2] x86/mm: set x32 syscall bit in SET_PERSONALITY()
References: <20170321163712.20334-1-dsafonov@virtuozzo.com>
 <20170321171723.GB21564@uranus.lan>
 <CALCETrXoxRBTon8+jrYcbruYVUZASwgd-kzH-A96DGvT7gLXVA@mail.gmail.com>
 <6648805c-e0d8-5e27-9e19-602ab47937a7@virtuozzo.com>
 <20170321184058.GD21564@uranus.lan>
 <dfdb16d4-aa6e-8635-1ea5-f6ac57b1dd05@virtuozzo.com>
 <20170321192419.GF21564@uranus.lan>
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Message-ID: <b2e73f20-0b0c-477f-0328-dec8d63a1b48@virtuozzo.com>
Date: Tue, 21 Mar 2017 22:34:57 +0300
MIME-Version: 1.0
In-Reply-To: <20170321192419.GF21564@uranus.lan>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Andy Lutomirski <luto@amacapital.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dmitry Safonov <0x7f454c46@gmail.com>, Adam Borowski <kilobyte@angband.pl>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrei Vagin <avagin@gmail.com>, Borislav Petkov <bp@suse.de>, "Kirill A.
 Shutemov" <kirill.shutemov@linux.intel.com>, X86 ML <x86@kernel.org>, "H.
 Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>

On 03/21/2017 10:24 PM, Cyrill Gorcunov wrote:
> On Tue, Mar 21, 2017 at 10:19:01PM +0300, Dmitry Safonov wrote:
>>>
>>> indeed, thanks!
>>
>> Also, even more simple-minded: for now we could just check binary magic
>> from /proc/.../exe, for now stopping on x32 binaries.
>
> File may not exist and elfheader wiped out as well.

Yep, not very reliable.

-- 
              Dmitry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
