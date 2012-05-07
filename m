Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id CDD7B6B004D
	for <linux-mm@kvack.org>; Mon,  7 May 2012 17:41:52 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so9144082pbb.14
        for <linux-mm@kvack.org>; Mon, 07 May 2012 14:41:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1205071514040.6029@router.home>
References: <CAP145pjtv-S2oHhn8_QfLKF8APtut4B9qPXK5QM8nQbxzPd2gw@mail.gmail.com>
	<alpine.DEB.2.00.1205071514040.6029@router.home>
Date: Mon, 7 May 2012 23:41:51 +0200
Message-ID: <CAP145piK2kW4F94pNdKpo_sGg8OD914exOtwCx2o+83jx5Toog@mail.gmail.com>
Subject: Re: mmap/clone returns ENOMEM with lots of free memory
From: =?UTF-8?B?Um9iZXJ0IMWad2nEmWNraQ==?= <robert@swiecki.net>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, May 7, 2012 at 10:15 PM, Christoph Lameter <cl@linux.com> wrote:
> On Mon, 7 May 2012, Robert =C5=9Awi=C4=99cki wrote:
>
>> root@ise-test:~/kern-fuz# ./cont.sh
>> su: Cannot fork user shell
>> su: Cannot fork user shell
>> su: Cannot fork user shell
>>
>> root@ise-test:~/kern-fuz# strace -e mmap,clone su test -c 'kill -CONT
>> -1' 2>&1 | grep "=3D \-1"
>> clone(child_stack=3D0,
>> flags=3DCLONE_CHILD_CLEARTID|CLONE_CHILD_SETTID|SIGCHLD,
>> child_tidptr=3D0x7fadf334f9f0) =3D -1 ENOMEM (Cannot allocate memory)
>> mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
>> 0) =3D -1 ENOMEM (Cannot allocate memory)
>
> Hmmm... That looks like some maximum virtual memory limit was violated.
>
> Check ulimit and the overcommit settings (see /proc/meminfo's commitlimit
> etc)

Yup (btw: I attached dump of some proc files and some debug commands
in the original e-mail - can be found here
http://marc.info/?l=3Dlinux-kernel&m=3D133640623421007&w=3D2 in case some
MTA removed them)

CommitLimit:     1981528 kB
Committed_AS:    1916788 kB

just not sure if Committed_AS should present this kind of value. Did I
just hit a legitimate condition, or may it suggest a bug? I'm a bit
puzzled cause

root@ise-test:/proc# grep Mem /proc/meminfo
MemTotal:        3963060 kB
MemFree:         3098324 kB

Also, some sysctl values:
vm.overcommit_memory =3D 2
vm.overcommit_ratio =3D 50

--=20
Robert =C5=9Awi=C4=99cki

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
