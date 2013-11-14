Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id A0DCE6B0044
	for <linux-mm@kvack.org>; Thu, 14 Nov 2013 02:55:24 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id kp14so110003pab.37
        for <linux-mm@kvack.org>; Wed, 13 Nov 2013 23:55:24 -0800 (PST)
Received: from psmtp.com ([74.125.245.110])
        by mx.google.com with SMTP id sg3si26682236pbb.73.2013.11.13.23.55.20
        for <linux-mm@kvack.org>;
        Wed, 13 Nov 2013 23:55:21 -0800 (PST)
Message-ID: <528481E2.9030707@nod.at>
Date: Thu, 14 Nov 2013 08:55:14 +0100
From: Richard Weinberger <richard@nod.at>
MIME-Version: 1.0
Subject: Re: [PATCH] arch: um: kernel: skas: mmu: remove pmd_free() and pud_free()
 for failure processing in init_stub_pte()
References: <alpine.LNX.2.00.1310150330350.9078@eggly.anvils> <528308E8.8040203@asianux.com> <alpine.LNX.2.00.1311132041200.1785@eggly.anvils> <52847237.5030405@asianux.com> <52847CD5.1030105@asianux.com>
In-Reply-To: <52847CD5.1030105@asianux.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <gang.chen@asianux.com>, Hugh Dickins <hughd@google.com>
Cc: Jeff Dike <jdike@addtoit.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, uml-devel <user-mode-linux-devel@lists.sourceforge.net>, uml-user <user-mode-linux-user@lists.sourceforge.net>

Am 14.11.2013 08:33, schrieb Chen Gang:
> On 11/14/2013 02:48 PM, Chen Gang wrote:
>>> >From the look of it, if an error did occur in init_stub_pte(),
>>>> then the special mapping of STUB_CODE and STUB_DATA would not
>>>> be installed, so this area would be invisible to munmap and exit,
>>>> and with your patch then the pages allocated likely to be leaked.
>>>>
>> It sounds reasonable to me: "although 'pgd' related with 'mm', but they
>> are not installed". But just like you said originally: "better get ACK
>> from some mm guys".
>>
>>
>> Hmm... is it another issue: "after STUB_CODE succeeds, but STUB_DATA
>> fails, the STUB_CODE will be leaked".
>>
>>
>>>> Which is not to say that the existing code is actually correct:
>>>> you're probably right that it's technically wrong.  But it would
>>>> be very hard to get init_stub_pte() to fail, and has anyone
>>>> reported a problem with it?  My guess is not, and my own
>>>> inclination to dabble here is zero.
>>>>
>> Yeah.
>>
> 
> If we can not get ACK from any mm guys, and we have no enough time
> resource to read related source code, for me, I still recommend to
> remove p?d_free() in failure processing.

It's rather easy, does your commit fix a real problem you are facing?
If the answer is "yes" we can talk.

Chen, If you really want to help us, please investigate into existing/real problems.
Toralf does a very good job in finding strange issues using trinity.
You could help him resolving the issue described in that thread:
"[uml-devel] fuzz tested 32 bit user mode linux image hangs in radix_tree_next_chunk()"

Thanks,
//richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
