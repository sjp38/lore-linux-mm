Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id A20D26B027A
	for <linux-mm@kvack.org>; Thu, 27 Oct 2016 14:52:33 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id i128so16100904wme.2
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 11:52:33 -0700 (PDT)
Received: from mx5-phx2.redhat.com (mx5-phx2.redhat.com. [209.132.183.37])
        by mx.google.com with ESMTPS id ho7si10123729wjb.156.2016.10.27.11.52.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Oct 2016 11:52:32 -0700 (PDT)
Date: Thu, 27 Oct 2016 14:51:30 -0400 (EDT)
From: Bob Peterson <rpeterso@redhat.com>
Message-ID: <411894642.13576957.1477594290544.JavaMail.zimbra@redhat.com>
In-Reply-To: <20161027123623.j2jri5bandimboff@pd.tnic>
References: <CAHc6FU4e5sueLi7pfeXnSbuuvnc5PaU3xo5Hnn=SvzmQ+ZOEeg@mail.gmail.com> <CA+55aFyRv0YttbLUYwDem=-L5ZAET026umh6LOUQ6hWaRur_VA@mail.gmail.com> <996124132.13035408.1477505043741.JavaMail.zimbra@redhat.com> <CA+55aFzVmppmua4U0pesp2moz7vVPbH1NP264EKeW3YqOzFc3A@mail.gmail.com> <1731570270.13088320.1477515684152.JavaMail.zimbra@redhat.com> <20161026231358.36jysz2wycdf4anf@pd.tnic> <624629879.13118306.1477528645189.JavaMail.zimbra@redhat.com> <20161027123623.j2jri5bandimboff@pd.tnic>
Subject: Re: CONFIG_VMAP_STACK, on-stack struct, and wake_up_bit
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Andreas Gruenbacher <agruenba@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Steven Whitehouse <swhiteho@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, linux-mm <linux-mm@kvack.org>

| Here's a fix which works here - I'd appreciate it if you ran it and
| checked the microcode was applied correctly, i.e.:
| 
| $ dmesg | grep -i microcode
| 
| before and after the patch. Please paste that output in a mail too.

Hi Borislav,

Sorry it's taken me so long. I've been having issues.
I couldn't recreate that first boot failure, even using .config.old,
and even after removing (rm -fR) my linux.git and untarring it from the
original tarball, doing a make clean, etc.
The output before and after your new patch are the same (except for the times):

# dmesg | grep -i microcode
[    5.291679] microcode: microcode updated early to new patch_level=0x010000d9
[    5.298761] microcode: CPU0: patch_level=0x010000d9
[    5.303648] microcode: CPU1: patch_level=0x010000d9
[    5.308529] microcode: CPU2: patch_level=0x010000d9
[    5.313414] microcode: CPU3: patch_level=0x010000d9
[    5.360834] microcode: CPU4: patch_level=0x010000d9
[    5.365719] microcode: CPU5: patch_level=0x010000d9
[    5.370602] microcode: CPU6: patch_level=0x010000d9
[    5.375486] microcode: CPU7: patch_level=0x010000d9
[    5.380372] microcode: CPU8: patch_level=0x010000d9
[    5.385256] microcode: CPU9: patch_level=0x010000d9
[    5.390142] microcode: CPU10: patch_level=0x010000d9
[    5.395102] microcode: CPU11: patch_level=0x010000d9
[    5.437813] microcode: CPU12: patch_level=0x010000d9
[    5.442785] microcode: CPU13: patch_level=0x010000d9
[    5.447755] microcode: CPU14: patch_level=0x010000d9
[    5.452724] microcode: CPU15: patch_level=0x010000d9
[    5.457756] microcode: Microcode Update Driver: v2.01 <tigran@aivazian.fsnet.co.uk>, Peter Oruba
# uname -a
Linux intec2 4.9.0-rc2+ #2 SMP Thu Oct 27 14:29:32 EDT 2016 x86_64 x86_64 x86_64 GNU/Linux

Regards,

Bob Peterson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
