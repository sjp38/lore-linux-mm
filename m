Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id A241F90010B
	for <linux-mm@kvack.org>; Thu, 26 May 2011 14:50:06 -0400 (EDT)
Received: by vxk20 with SMTP id 20so1123313vxk.14
        for <linux-mm@kvack.org>; Thu, 26 May 2011 11:50:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTi=znC18PAbpDfeVO+=Pat_EeXddjw@mail.gmail.com>
References: <4DDE2873.7060409@jp.fujitsu.com>
	<BANLkTi=znC18PAbpDfeVO+=Pat_EeXddjw@mail.gmail.com>
Date: Thu, 26 May 2011 20:50:02 +0200
Message-ID: <BANLkTikgXhmgzQYfSWKDoxVyNuCzSM7Qxw@mail.gmail.com>
Subject: Re: [PATCH] mm: don't access vm_flags as 'int'
From: richard -rw- weinberger <richard.weinberger@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, benh@kernel.crashing.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hughd@google.com, akpm@linux-foundation.org, dave@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com

On Thu, May 26, 2011 at 7:53 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> 2011/5/26 KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>:
>> The type of vma->vm_flags is 'unsigned long'. Neither 'int' nor
>> 'unsigned int'. This patch fixes such misuse.
>
> I applied this, except I also just made the executive decision to
> replace things with "vm_flags_t" after all.
>
> Which leaves a lot of "unsigned long" users that aren't converted, but
> right now it doesn't matter, and it can be converted piecemeal as
> people notice users..
>

This breaks kernel builds with CONFIG_HUGETLBFS=3Dn. :-(

In file included from fs/proc/meminfo.c:2:0:
include/linux/hugetlb.h:195:3: error: expected declaration specifiers
or =91...=92 before =91vm_flags_t=92
  CC      drivers/ata/libata-pmp.o
make[2]: *** [fs/proc/meminfo.o] Fehler 1
make[1]: *** [fs/proc] Fehler 2
make: *** [fs] Fehler 2
make: *** Warte auf noch nicht beendete Prozesse...


--=20
Thanks,
//richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
