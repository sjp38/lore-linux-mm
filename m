Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 02FE98D0001
	for <linux-mm@kvack.org>; Fri, 26 Nov 2010 11:46:40 -0500 (EST)
Received: by ywa8 with SMTP id 8so501896ywa.14
        for <linux-mm@kvack.org>; Fri, 26 Nov 2010 08:46:38 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101124105126.8248fc1f.randy.dunlap@oracle.com>
References: <201011240045.oAO0jYQ5016010@imap1.linux-foundation.org>
	<20101124105126.8248fc1f.randy.dunlap@oracle.com>
Date: Fri, 26 Nov 2010 16:46:38 +0000
Message-ID: <AANLkTik8G7ZQ5Dujcf0rKsctMLqsJUPPQQ+wMJ1Wxbon@mail.gmail.com>
Subject: Re: mmotm 2010-11-23-16-12 uploaded (olpc)
From: Daniel Drake <dsd@laptop.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: akpm@linux-foundation.org, Andres Salomon <dilinger@debian.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 24 November 2010 18:51, Randy Dunlap <randy.dunlap@oracle.com> wrote:
> make[4]: *** No rule to make target `arch/x86/platform/olpc/olpc-xo1-wakeup.c', needed by `arch/x86/platform/olpc/olpc-xo1-wakeup.o'.
>
>
> It's olpc-xo1-wakeup.S, so I guess it needs a special makefile rule ??

Works if you build it in, but fails as above as a module.

And it looks like making it work as a module is not as easy as we
thought. I'll discuss this with Andres and get a new patch submitted
soon.

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
