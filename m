Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id BDBD082F87
	for <linux-mm@kvack.org>; Thu,  1 Oct 2015 18:39:03 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so88932037pac.2
        for <linux-mm@kvack.org>; Thu, 01 Oct 2015 15:39:03 -0700 (PDT)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id rm9si11937644pab.83.2015.10.01.15.39.03
        for <linux-mm@kvack.org>;
        Thu, 01 Oct 2015 15:39:03 -0700 (PDT)
Subject: Re: [PATCH 26/26] x86, pkeys: Documentation
References: <20150916174903.E112E464@viggo.jf.intel.com>
 <20150916174913.AF5FEA6D@viggo.jf.intel.com>
 <20150920085554.GA21906@gmail.com> <55FF88BA.6080006@sr71.net>
 <20150924094956.GA30349@gmail.com> <56044A88.7030203@sr71.net>
 <20151001111718.GA25333@gmail.com>
 <CAGXu5j+j92EPEwv9O4cX92zJDTyBEz3WtQ2CDHT0KmqJ6bCmGQ@mail.gmail.com>
 <560DB4A6.6050107@sr71.net>
 <CAGXu5jK5WT7u18Tee6XtwxMLTaWbV2PiNA4opWTox+DB5BT7gQ@mail.gmail.com>
From: Dave Hansen <dave@sr71.net>
Message-ID: <560DB605.2000402@sr71.net>
Date: Thu, 1 Oct 2015 15:39:01 -0700
MIME-Version: 1.0
In-Reply-To: <CAGXu5jK5WT7u18Tee6XtwxMLTaWbV2PiNA4opWTox+DB5BT7gQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@google.com>
Cc: Ingo Molnar <mingo@kernel.org>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>

On 10/01/2015 03:35 PM, Kees Cook wrote:
> On Thu, Oct 1, 2015 at 3:33 PM, Dave Hansen <dave@sr71.net> wrote:
>> On 10/01/2015 01:39 PM, Kees Cook wrote:
>>> On Thu, Oct 1, 2015 at 4:17 AM, Ingo Molnar <mingo@kernel.org> wrote:
>>>> So could we try to add an (opt-in) kernel option that enables this transparently
>>>> and automatically for all PROT_EXEC && !PROT_WRITE mappings, without any
>>>> user-space changes and syscalls necessary?
>>>
>>> I would like this very much. :)
>>
>> Here it is in a quite fugly form (well, it's not opt-in).  Init crashes
>> if I boot with this, though.
> 
> *laugh* Okay... well, we've got some work to do, I guess. :)
> 
> (And which init?)

systemd for better or worse.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
