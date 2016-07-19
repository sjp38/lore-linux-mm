Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 025C16B0005
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 16:45:10 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id o80so20281054wme.1
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 13:45:09 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id j194si22318170wmf.146.2016.07.19.13.45.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jul 2016 13:45:08 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u6JKiUG0016797
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 16:45:07 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2495r920rv-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 16:45:06 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Tue, 19 Jul 2016 21:45:05 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id A261A17D8067
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 21:46:32 +0100 (BST)
Received: from d06av08.portsmouth.uk.ibm.com (d06av08.portsmouth.uk.ibm.com [9.149.37.249])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u6JKj3Bc9896226
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 20:45:03 GMT
Received: from d06av08.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av08.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u6JKj0qL003957
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 14:45:02 -0600
Subject: Re: [PATCH v3 02/11] mm: Hardened usercopy
References: <1468619065-3222-1-git-send-email-keescook@chromium.org>
 <1468619065-3222-3-git-send-email-keescook@chromium.org>
 <578DF109.5030704@de.ibm.com>
 <CAGXu5jKRDuELqGY1F-D4+MD+dMXSbiPGzf1hXb7Kp8ACBjpw9g@mail.gmail.com>
 <578E8A22.5080807@de.ibm.com>
 <CAGXu5j+HqLY1gZycV9S9_Vf8uuQj4Z3qsV8WBxLORuseiJaw5Q@mail.gmail.com>
From: Christian Borntraeger <borntraeger@de.ibm.com>
Date: Tue, 19 Jul 2016 22:44:58 +0200
MIME-Version: 1.0
In-Reply-To: <CAGXu5j+HqLY1gZycV9S9_Vf8uuQj4Z3qsV8WBxLORuseiJaw5Q@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Message-Id: <578E914A.7070900@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Balbir Singh <bsingharora@gmail.com>, Daniel Micay <danielmicay@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Rik van Riel <riel@redhat.com>, Casey Schaufler <casey@schaufler-ca.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "David S. Miller" <davem@davemloft.net>, "x86@kernel.org" <x86@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Jan Kara <jack@suse.cz>, Vitaly Wool <vitalywool@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, linux-ia64@vger.kernel.org, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, sparclinux <sparclinux@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On 07/19/2016 10:34 PM, Kees Cook wrote:
[...]
>>
>> So what about for the CONFIG text:
>>
>>        An architecture should select this if the kernel mapping has a secondary
>>        linear mapping of the kernel text - in other words more than one virtual
>>        kernel address that points to the kernel image. This is used to verify
>>        that kernel text exposures are not visible under CONFIG_HARDENED_USERCOPY.
> 
> Sounds good, I've adjusted it for now.
> 
>>> I wonder if I can avoid the CONFIG entirely if I just did a
>>> __va(__pa(_stext)) != _stext test... would that break anyone?
>>
>> Can this be resolved on all platforms at compile time?
> 
> Well, I think it still needs a runtime check (compile-time may not be
> able to tell about kaslr, or who knows what else). I would really like
> to avoid the CONFIG if possible, though. Would this do the right thing
> on s390? This appears to work where I'm able to test it (32/64 x86,
> 32/64 arm):
> 
>         unsigned long textlow = (unsigned long)_stext;
>         unsigned long texthigh = (unsigned long)_etext;
>         unsigned long textlow_linear = (unsigned long)__va(__pa(textlow);
>         unsigned long texthigh_linear = (unsigned long)__va(__pa(texthigh);
> 
as we have

#define PAGE_OFFSET             0x0UL
#define __pa(x)                 (unsigned long)(x)
#define __va(x)                 (void *)(unsigned long)(x)

both should be identical on s390 as of today, so it should work fine and only
do the check once

>         if (overlaps(ptr, n, textlow, texthigh))
>                 return "<kernel text>";
> 
>         /* Check against possible secondary linear mapping as well. */
>         if (textlow != textlow_linear &&
>             overlaps(ptr, n, textlow_linear, texthigh_linear))
>                 return "<linear kernel text>";
> 
>         return NULL;
> 
> 
> -Kees
> 


PS: Not sure how useful and flexible this offers is but you can get some temporary
free access to an s390 on https://developer.ibm.com/linuxone/




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
