Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C80216B004F
	for <linux-mm@kvack.org>; Wed, 12 Aug 2009 01:07:47 -0400 (EDT)
Received: by ey-out-1920.google.com with SMTP id 13so1404397eye.44
        for <linux-mm@kvack.org>; Tue, 11 Aug 2009 22:07:48 -0700 (PDT)
MIME-Version: 1.0
Reply-To: mtk.manpages@gmail.com
In-Reply-To: <a45eb555ca7d9e23e5eb051e27f757ae70a6b0c5.1249999949.git.ebmunson@us.ibm.com>
References: <cover.1249999949.git.ebmunson@us.ibm.com>
	 <2154e5ac91c7acd5505c5fc6c55665980cbc1bf8.1249999949.git.ebmunson@us.ibm.com>
	 <a45eb555ca7d9e23e5eb051e27f757ae70a6b0c5.1249999949.git.ebmunson@us.ibm.com>
Date: Wed, 12 Aug 2009 07:07:48 +0200
Message-ID: <cfd18e0f0908112207y186d0aav6e0e55ce070778cf@mail.gmail.com>
Subject: Re: [PATCH 2/3] Add MAP_LARGEPAGE for mmaping pseudo-anonymous huge
	page regions
From: Michael Kerrisk <mtk.manpages@googlemail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Eric B Munson <ebmunson@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Eric,

On Wed, Aug 12, 2009 at 12:13 AM, Eric B Munson<ebmunson@us.ibm.com> wrote:
> This patch adds a flag for mmap that will be used to request a huge
> page region that will look like anonymous memory to user space. =A0This
> is accomplished by using a file on the internal vfsmount. =A0MAP_LARGEPAG=
E
> is a modifier of MAP_ANONYMOUS and so must be specified with it. =A0The
> region will behave the same as a MAP_ANONYMOUS region using small pages.

Does this flag provide functionality analogous to shmget(SHM_HUGETLB)?
If so, would iot not make sense to name it similarly (i.e.,
MAP_HUGETLB)?

Cheers,

Michael

--=20
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Watch my Linux system programming book progress to publication!
http://blog.man7.org/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
