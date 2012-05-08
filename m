Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 4B6DB6B00EF
	for <linux-mm@kvack.org>; Tue,  8 May 2012 10:47:38 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so10467663pbb.14
        for <linux-mm@kvack.org>; Tue, 08 May 2012 07:47:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1205080859570.25669@router.home>
References: <CAP145pjtv-S2oHhn8_QfLKF8APtut4B9qPXK5QM8nQbxzPd2gw@mail.gmail.com>
	<alpine.DEB.2.00.1205071514040.6029@router.home>
	<CAP145piK2kW4F94pNdKpo_sGg8OD914exOtwCx2o+83jx5Toog@mail.gmail.com>
	<alpine.DEB.2.00.1205080859570.25669@router.home>
Date: Tue, 8 May 2012 16:47:37 +0200
Message-ID: <CAP145phLFDzoop_kUq-qN8a132Dj4oXsxJGcR_rv+LbZV-NObA@mail.gmail.com>
Subject: Re: mmap/clone returns ENOMEM with lots of free memory
From: =?UTF-8?B?Um9iZXJ0IMWad2nEmWNraQ==?= <robert@swiecki.net>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, May 8, 2012 at 4:02 PM, Christoph Lameter <cl@linux.com> wrote:
> On Mon, 7 May 2012, Robert =C5=9Awi=C4=99cki wrote:
>
>> Yup (btw: I attached dump of some proc files and some debug commands
>> in the original e-mail - can be found here
>> http://marc.info/?l=3Dlinux-kernel&m=3D133640623421007&w=3D2 in case som=
e
>> MTA removed them)
>>
>> CommitLimit: =C2=A0 =C2=A0 1981528 kB
>> Committed_AS: =C2=A0 =C2=A01916788 kB
>>
>> just not sure if Committed_AS should present this kind of value. Did I
>> just hit a legitimate condition, or may it suggest a bug? I'm a bit
>> puzzled cause
>
> This is a legitimate condition. No bug.
>>
>> root@ise-test:/proc# grep Mem /proc/meminfo
>> MemTotal: =C2=A0 =C2=A0 =C2=A0 =C2=A03963060 kB
>> MemFree: =C2=A0 =C2=A0 =C2=A0 =C2=A0 3098324 kB
>
> Physical memory is free in quantity but virtual memory is exhausted.
>
>> Also, some sysctl values:
>> vm.overcommit_memory =3D 2
>> vm.overcommit_ratio =3D 50
>
> Setting overcommit memory to 2 means that the app is strictly policed
> for staying within bounds on virtual memory. Dont do that.
>
> See linux source linux/Documentation/vm/overcommit-accounting for more
> details.

Thanks Christoph.

--=20
Robert =C5=9Awi=C4=99cki

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
