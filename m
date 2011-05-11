Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id B5D846B0023
	for <linux-mm@kvack.org>; Wed, 11 May 2011 00:49:24 -0400 (EDT)
Received: by iwg8 with SMTP id 8so273668iwg.14
        for <linux-mm@kvack.org>; Tue, 10 May 2011 21:49:23 -0700 (PDT)
MIME-Version: 1.0
From: Tharindu Rukshan Bamunuarachchi <btharindu@gmail.com>
Date: Wed, 11 May 2011 10:18:53 +0530
Message-ID: <BANLkTi=F2RrzBHDUrRpPvzYyT2Q7FDPWug@mail.gmail.com>
Subject: CLONE_VM unsharing
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hello,

According to ushare_vm function, unsharing mm_struct has not been
implemented yet. Am I mistaken ?

static int unshare_vm(unsigned long unshare_flags, struct mm_struct **new_m=
mp)
{
=C2=A0 struct mm_struct *mm =3D current->mm;
=C2=A0 if ((unshare_flags & CLONE_VM) &&
=C2=A0 =C2=A0 =C2=A0 (mm && atomic_read(&mm->mm_users) > 1)) {
=C2=A0 =C2=A0 return -EINVAL;
=C2=A0 }
=C2=A0 return 0;
}

Would it be enough to=C2=A0duplicate=C2=A0mm_struct here if i need usharing=
 of VM ?

__
Tharindu "R" Bamunuarachchi.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
