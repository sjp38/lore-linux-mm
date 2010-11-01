Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 05D8B8D0030
	for <linux-mm@kvack.org>; Mon,  1 Nov 2010 03:06:00 -0400 (EDT)
Date: Mon, 1 Nov 2010 16:05:48 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: RFC: reviving mlock isolation dead code
In-Reply-To: <AANLkTik4NM5YOgh48bOWDQZuUKmEHLH6Ja10eOzn-_tj@mail.gmail.com>
References: <AANLkTik4NM5YOgh48bOWDQZuUKmEHLH6Ja10eOzn-_tj@mail.gmail.com>
Message-Id: <20101101015311.6062.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Michel Lespinasse <walken@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hello,

> I would like to resurect this, as I am seeing problems during a large
> mlock (many GB). The mlock takes a long time to complete
> (__mlock_vma_pages_range() is loading pages from disk), there is
> memory pressure as some pages have to be evicted to make room for the
> large mlock, and the LRU algorithm performs badly with the high amount
> of pages still on LRU list - PageMlocked has not been set yet - while
> their VMA is already VM_LOCKED.
>=20
> One approach I am considering would be to modify
> __mlock_vma_pages_range() and it call sites so the mmap sem is only
> read-owned while __mlock_vma_pages_range() runs. The mlock handling
> code in try_to_unmap_one() would then be able to acquire the
> mmap_sem() and help, as it is designed to do.

I would like to talk historical story a bit. Originally, Lee designed it as=
 you proposed.=20
but Linus refused it. He thought ro-rwsem is bandaid fix. That is one of re=
ason that
some developers seeks proper mmap_sem dividing way.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
