Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id AC6666B004D
	for <linux-mm@kvack.org>; Mon,  7 May 2012 16:36:20 -0400 (EDT)
Date: Mon, 7 May 2012 15:15:46 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: mmap/clone returns ENOMEM with lots of free memory
In-Reply-To: <CAP145pjtv-S2oHhn8_QfLKF8APtut4B9qPXK5QM8nQbxzPd2gw@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1205071514040.6029@router.home>
References: <CAP145pjtv-S2oHhn8_QfLKF8APtut4B9qPXK5QM8nQbxzPd2gw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/Mixed; BOUNDARY=047d7b10c86d14f88404bf744902
Content-ID: <alpine.DEB.2.00.1205071514041.6029@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?ISO-8859-2?Q?Robert_=A6wi=EAcki?= <robert@swiecki.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--047d7b10c86d14f88404bf744902
Content-Type: TEXT/PLAIN; CHARSET=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Content-ID: <alpine.DEB.2.00.1205071514042.6029@router.home>

On Mon, 7 May 2012, Robert =C5=9Awi=C4=99cki wrote:

> root@ise-test:~/kern-fuz# ./cont.sh
> su: Cannot fork user shell
> su: Cannot fork user shell
> su: Cannot fork user shell
>
> root@ise-test:~/kern-fuz# strace -e mmap,clone su test -c 'kill -CONT
> -1' 2>&1 | grep "=3D \-1"
> clone(child_stack=3D0,
> flags=3DCLONE_CHILD_CLEARTID|CLONE_CHILD_SETTID|SIGCHLD,
> child_tidptr=3D0x7fadf334f9f0) =3D -1 ENOMEM (Cannot allocate memory)
> mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
> 0) =3D -1 ENOMEM (Cannot allocate memory)

Hmmm... That looks like some maximum virtual memory limit was violated.

Check ulimit and the overcommit settings (see /proc/meminfo's commitlimit
etc)

--047d7b10c86d14f88404bf744902--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
