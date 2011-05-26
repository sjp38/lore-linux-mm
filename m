Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 2D00E90010B
	for <linux-mm@kvack.org>; Thu, 26 May 2011 14:50:56 -0400 (EDT)
Received: from mail-ey0-f169.google.com (mail-ey0-f169.google.com [209.85.215.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p4QIoNeY008789
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Thu, 26 May 2011 11:50:25 -0700
Received: by eyd9 with SMTP id 9so563677eyd.14
        for <linux-mm@kvack.org>; Thu, 26 May 2011 11:50:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110526184402.GA2453@p183.telecom.by>
References: <4DDE2873.7060409@jp.fujitsu.com> <BANLkTi=znC18PAbpDfeVO+=Pat_EeXddjw@mail.gmail.com>
 <20110526184402.GA2453@p183.telecom.by>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 26 May 2011 11:49:59 -0700
Message-ID: <BANLkTi=Z=AoEH_AyN370jiUq7Qm1RhM0gQ@mail.gmail.com>
Subject: Re: [PATCH] mm: don't access vm_flags as 'int'
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, benh@kernel.crashing.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hughd@google.com, akpm@linux-foundation.org, dave@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com

On Thu, May 26, 2011 at 11:44 AM, Alexey Dobriyan <adobriyan@gmail.com> wrote:
>
> Woo-hoo!
>
> Why it is marked __nocast and not __bitwise__ like gfp_t?

Because that's what one of the other patches in Andrew's series had,
so I just emulated that.

Also, I don't think we can currently mark it __bitwise without causing
a sh*tload of sparse warnings. __nocast is much weaker than bitwise
(it only warns about implicit casts to different sizes). __bitwise
implies a lot more type-checking, and actually makes the result a very
specific type.

I'm not sure it is worth the __bitwise pain. If we go down the
__bitwise path, we'd need to mark all the VM_XYZZY constants with the
type, and we'd need to do *all* the conversions in one go. I am
definitely not ready to do that at this stage, but I was willing to
take the much weaker __nocast.

                    Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
