Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 23A1E6B00E7
	for <linux-mm@kvack.org>; Tue,  8 May 2012 10:02:49 -0400 (EDT)
Date: Tue, 8 May 2012 09:02:46 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: mmap/clone returns ENOMEM with lots of free memory
In-Reply-To: <CAP145piK2kW4F94pNdKpo_sGg8OD914exOtwCx2o+83jx5Toog@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1205080859570.25669@router.home>
References: <CAP145pjtv-S2oHhn8_QfLKF8APtut4B9qPXK5QM8nQbxzPd2gw@mail.gmail.com> <alpine.DEB.2.00.1205071514040.6029@router.home> <CAP145piK2kW4F94pNdKpo_sGg8OD914exOtwCx2o+83jx5Toog@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811839-1884713895-1336485767=:25669"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?ISO-8859-2?Q?Robert_=A6wi=EAcki?= <robert@swiecki.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811839-1884713895-1336485767=:25669
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Mon, 7 May 2012, Robert =C5=9Awi=C4=99cki wrote:

> Yup (btw: I attached dump of some proc files and some debug commands
> in the original e-mail - can be found here
> http://marc.info/?l=3Dlinux-kernel&m=3D133640623421007&w=3D2 in case some
> MTA removed them)
>
> CommitLimit:     1981528 kB
> Committed_AS:    1916788 kB
>
> just not sure if Committed_AS should present this kind of value. Did I
> just hit a legitimate condition, or may it suggest a bug? I'm a bit
> puzzled cause

This is a legitimate condition. No bug.
>
> root@ise-test:/proc# grep Mem /proc/meminfo
> MemTotal:        3963060 kB
> MemFree:         3098324 kB

Physical memory is free in quantity but virtual memory is exhausted.

> Also, some sysctl values:
> vm.overcommit_memory =3D 2
> vm.overcommit_ratio =3D 50

Setting overcommit memory to 2 means that the app is strictly policed
for staying within bounds on virtual memory. Dont do that.

See linux source linux/Documentation/vm/overcommit-accounting for more
details.


---1463811839-1884713895-1336485767=:25669--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
