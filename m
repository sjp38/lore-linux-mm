Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 391016B0038
	for <linux-mm@kvack.org>; Fri, 31 Mar 2017 01:44:52 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id 13so22310026ioe.13
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 22:44:52 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0106.outbound.protection.outlook.com. [104.47.1.106])
        by mx.google.com with ESMTPS id 124si1514914itz.32.2017.03.30.22.44.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 30 Mar 2017 22:44:51 -0700 (PDT)
Subject: Re: sudo x86info -a => kernel BUG at mm/usercopy.c:78!
References: <d928849c-e7c3-6b81-e551-a39fa976f341@nokia.com>
 <CAGXu5jKo4gw=RHCmcY3v+GTiUUgteLbmvHDghd-Lrm7RprL8=Q@mail.gmail.com>
 <3890813c-c891-89a5-c16f-66240a794319@redhat.com>
 <CAGXu5jLSp737ZQEtyO7AZCHbmtEj55Q5UVjGQX-SS_rc2upuJA@mail.gmail.com>
 <a0abf5c5-f2f1-04f4-d660-f8c70042b11b@redhat.com>
From: Tommi Rantala <tommi.t.rantala@nokia.com>
Message-ID: <bc2fa666-cbfb-e78d-39f7-be7ab66bf34d@nokia.com>
Date: Fri, 31 Mar 2017 08:44:43 +0300
MIME-Version: 1.0
In-Reply-To: <a0abf5c5-f2f1-04f4-d660-f8c70042b11b@redhat.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>, Kees Cook <keescook@chromium.org>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Mark Rutland <mark.rutland@arm.com>, Eric Biggers <ebiggers@google.com>, Dave Jones <davej@codemonkey.org.uk>

On 30.03.2017 20:44, Laura Abbott wrote:
> On 03/30/2017 10:37 AM, Kees Cook wrote:
>>
>> Reads out of /dev/mem should be restricted to non-RAM on Fedora, yes?
>>
>> Tommi, do your kernels have CONFIG_STRICT_DEVMEM=y ?
>>
>> -Kees
>>
>
> CONFIG_STRICT_DEVMEM should be on in all Fedora kernels.

Yes, the fedora kernels do have it enabled:

   $ grep STRICT_DEVMEM /boot/config-4.9.14-200.fc25.x86_64
   CONFIG_STRICT_DEVMEM=y
   CONFIG_IO_STRICT_DEVMEM=y

But I do not have it in my own build:

   $ grep STRICT_DEVMEM .config
   # CONFIG_STRICT_DEVMEM is not set

-Tommi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
