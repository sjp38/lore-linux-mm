Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 2661682F87
	for <linux-mm@kvack.org>; Thu,  1 Oct 2015 16:58:09 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so86719578pac.2
        for <linux-mm@kvack.org>; Thu, 01 Oct 2015 13:58:08 -0700 (PDT)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id te1si11441115pac.31.2015.10.01.13.58.08
        for <linux-mm@kvack.org>;
        Thu, 01 Oct 2015 13:58:08 -0700 (PDT)
Subject: Re: [PATCH 26/26] x86, pkeys: Documentation
References: <20150916174903.E112E464@viggo.jf.intel.com>
 <20150916174913.AF5FEA6D@viggo.jf.intel.com>
 <20150920085554.GA21906@gmail.com> <55FF88BA.6080006@sr71.net>
 <20150924094956.GA30349@gmail.com> <56044A88.7030203@sr71.net>
 <20151001111718.GA25333@gmail.com>
 <CAGXu5j+j92EPEwv9O4cX92zJDTyBEz3WtQ2CDHT0KmqJ6bCmGQ@mail.gmail.com>
From: Dave Hansen <dave@sr71.net>
Message-ID: <560D9E5C.4090605@sr71.net>
Date: Thu, 1 Oct 2015 13:58:04 -0700
MIME-Version: 1.0
In-Reply-To: <CAGXu5j+j92EPEwv9O4cX92zJDTyBEz3WtQ2CDHT0KmqJ6bCmGQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@google.com>, Ingo Molnar <mingo@kernel.org>
Cc: "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>

On 10/01/2015 01:39 PM, Kees Cook wrote:
> On Thu, Oct 1, 2015 at 4:17 AM, Ingo Molnar <mingo@kernel.org> wrote:
>> * Dave Hansen <dave@sr71.net> wrote:
>>>> If yes then this could be a significant security feature / usecase for pkeys:
> 
> Which CPUs (will) have pkeys?

It hasn't been announced publicly, so all I can say here is "future ones".

>>>> executable sections of shared libraries and binaries could be mapped with pkey
>>>> access disabled. If I read the Intel documentation correctly then that should
>>>> be possible.
>>>
>>> Agreed.  I've even heard from some researchers who are interested in this:
>>>
>>> https://www.infsec.cs.uni-saarland.de/wp-content/uploads/sites/2/2014/10/nuernberger2014ccs_disclosure.pdf
>>
>> So could we try to add an (opt-in) kernel option that enables this transparently
>> and automatically for all PROT_EXEC && !PROT_WRITE mappings, without any
>> user-space changes and syscalls necessary?
> 
> I would like this very much. :)

I'll go hack something together and see what breaks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
