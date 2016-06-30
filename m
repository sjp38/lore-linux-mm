Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 733D4828E1
	for <linux-mm@kvack.org>; Thu, 30 Jun 2016 13:40:38 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id b136so20150842qkg.3
        for <linux-mm@kvack.org>; Thu, 30 Jun 2016 10:40:38 -0700 (PDT)
Received: from mail-vk0-x22f.google.com (mail-vk0-x22f.google.com. [2607:f8b0:400c:c05::22f])
        by mx.google.com with ESMTPS id h91si1019644uad.170.2016.06.30.10.40.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Jun 2016 10:40:37 -0700 (PDT)
Received: by mail-vk0-x22f.google.com with SMTP id k68so33436909vkb.0
        for <linux-mm@kvack.org>; Thu, 30 Jun 2016 10:40:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <57754CEA.6070900@sr71.net>
References: <20160609000117.71AC7623@viggo.jf.intel.com> <20160630094123.GA29268@gmail.com>
 <57754CEA.6070900@sr71.net>
From: Andy Lutomirski <luto@amacapital.net>
Date: Thu, 30 Jun 2016 10:40:17 -0700
Message-ID: <CALCETrUgYxT7ts1HAtL6_49BY1N=FqzO1VDBHJZiG_=kBYHxRg@mail.gmail.com>
Subject: Re: [PATCH 0/9] [v3] System Calls for Memory Protection Keys
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: Ingo Molnar <mingo@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, Linux API <linux-api@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Al Viro <viro@zeniv.linux.org.uk>, Mel Gorman <mgorman@techsingularity.net>, Hugh Dickins <hughd@google.com>

On Thu, Jun 30, 2016 at 9:46 AM, Dave Hansen <dave@sr71.net> wrote:
> On 06/30/2016 02:41 AM, Ingo Molnar wrote:
>> * Dave Hansen <dave@sr71.net> wrote:
>>> Are there any concerns with merging these into the x86 tree so
>>> that they go upstream for 4.8?  The updates here are pretty
>>> minor.
>>
>>>  include/linux/pkeys.h                         |   39 +-
>>>  include/uapi/asm-generic/mman-common.h        |    5 +
>>>  include/uapi/asm-generic/unistd.h             |   12 +-
>>>  mm/mprotect.c                                 |  134 +-
>>
>> So I'd love to have some high level MM review & ack for these syscall ABI
>> extensions.
>
> That's a quite reasonable request, but I'm really surprised by it at
> this point.  The proposed ABI is one very straightforward extension to
> one existing system call, plus four others that you personally suggested.
>

I apologize for the very late review, but (see other thread) I think
we may need to make sure we've defined the signal delivery semantics
in a useful way before enabling these.  I'm not convinced that the
current behavior is helpful.  This may or may not require any change
to the syscall signatures, but I can imagine that doing it right would
involve adding another syscall to *read* the current signal-delivery
state of a pkey or perhaps of all the pkeys.  That could potentially
be achieved by adding an extra pointer parameter to pkey_get so
pkey_get can return both the current state and the state at next
signal delivery.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
