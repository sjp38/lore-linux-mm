Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7B8306B0253
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 18:26:03 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id z67so216855743pgb.0
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 15:26:03 -0800 (PST)
Received: from icp-osb-irony-out5.external.iinet.net.au (icp-osb-irony-out5.external.iinet.net.au. [203.59.1.221])
        by mx.google.com with ESMTP id 31si17062051plk.154.2017.01.23.15.26.01
        for <linux-mm@kvack.org>;
        Mon, 23 Jan 2017 15:26:02 -0800 (PST)
Subject: Re: [Ksummit-discuss] security-related TODO items?
References: <CALCETrV5b4Z3MF51pQOPtp-BgMM4TYPLrXPHL+EfsWfm+CczkA@mail.gmail.com>
 <CAGXu5j+nVMPk3TTxLr3_6Y=5vNM0=aD+13JM_Q5POts9M7kzuw@mail.gmail.com>
 <CALCETrVKDAzcS62wTjDOGuRUNec_a-=8iEa7QQ62V83Ce2nk=A@mail.gmail.com>
 <31033.1485168526@warthog.procyon.org.uk>
 <5024.1485203788@warthog.procyon.org.uk>
From: Greg Ungerer <gregungerer@westnet.com.au>
Message-ID: <811e58f6-0475-e9cd-f136-9a4504073df1@westnet.com.au>
Date: Tue, 24 Jan 2017 09:26:03 +1000
MIME-Version: 1.0
In-Reply-To: <5024.1485203788@warthog.procyon.org.uk>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Howells <dhowells@redhat.com>, Andy Lutomirski <luto@amacapital.net>
Cc: Josh Armour <jarmour@google.com>, "ksummit-discuss@lists.linuxfoundation.org" <ksummit-discuss@lists.linuxfoundation.org>, Greg KH <gregkh@linuxfoundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 24/01/17 06:36, David Howells wrote:
> Andy Lutomirski <luto@amacapital.net> wrote:
[snip]
>>>  (6) NOMMU could be particularly tricky.  For ELF-FDPIC at least, the stack
>>>      size is set in the binary.  OTOH, you wouldn't have to relocate the
>>>      pre-loader - you'd just mmap it MAP_PRIVATE and execute in place.
>>
>> For nommu, forget about it.
> 
> Why?  If you do that, you have to have bimodal binfmts.  Note that the
> ELF-FDPIC binfmt, at least, can be used for both MMU and NOMMU environments.
> This may also be true of FLAT.

It is true for FLAT as well, they can run on both MMU an noMMU.

Regards
Greg


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
