Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f172.google.com (mail-io0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id CC14C82F87
	for <linux-mm@kvack.org>; Thu,  1 Oct 2015 18:35:44 -0400 (EDT)
Received: by ioii196 with SMTP id i196so102106763ioi.3
        for <linux-mm@kvack.org>; Thu, 01 Oct 2015 15:35:44 -0700 (PDT)
Received: from mail-io0-x235.google.com (mail-io0-x235.google.com. [2607:f8b0:4001:c06::235])
        by mx.google.com with ESMTPS id g76si6539305ioj.81.2015.10.01.15.35.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Oct 2015 15:35:44 -0700 (PDT)
Received: by iofh134 with SMTP id h134so102632838iof.0
        for <linux-mm@kvack.org>; Thu, 01 Oct 2015 15:35:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <560DB4A6.6050107@sr71.net>
References: <20150916174903.E112E464@viggo.jf.intel.com>
	<20150916174913.AF5FEA6D@viggo.jf.intel.com>
	<20150920085554.GA21906@gmail.com>
	<55FF88BA.6080006@sr71.net>
	<20150924094956.GA30349@gmail.com>
	<56044A88.7030203@sr71.net>
	<20151001111718.GA25333@gmail.com>
	<CAGXu5j+j92EPEwv9O4cX92zJDTyBEz3WtQ2CDHT0KmqJ6bCmGQ@mail.gmail.com>
	<560DB4A6.6050107@sr71.net>
Date: Thu, 1 Oct 2015 15:35:43 -0700
Message-ID: <CAGXu5jK5WT7u18Tee6XtwxMLTaWbV2PiNA4opWTox+DB5BT7gQ@mail.gmail.com>
Subject: Re: [PATCH 26/26] x86, pkeys: Documentation
From: Kees Cook <keescook@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: Ingo Molnar <mingo@kernel.org>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>

On Thu, Oct 1, 2015 at 3:33 PM, Dave Hansen <dave@sr71.net> wrote:
> On 10/01/2015 01:39 PM, Kees Cook wrote:
>> On Thu, Oct 1, 2015 at 4:17 AM, Ingo Molnar <mingo@kernel.org> wrote:
>>> So could we try to add an (opt-in) kernel option that enables this transparently
>>> and automatically for all PROT_EXEC && !PROT_WRITE mappings, without any
>>> user-space changes and syscalls necessary?
>>
>> I would like this very much. :)
>
> Here it is in a quite fugly form (well, it's not opt-in).  Init crashes
> if I boot with this, though.

*laugh* Okay... well, we've got some work to do, I guess. :)

(And which init?)

> I'll see if I can turn it in to a bit more of an opt-in and see what's
> actually going wrong.

Cool, thanks!

-Kees

-- 
Kees Cook
Chrome OS Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
