Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id A60806B004D
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 21:37:57 -0400 (EDT)
Message-ID: <5018897E.4040109@cn.fujitsu.com>
Date: Wed, 01 Aug 2012 09:42:22 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v5 12/19] memory-hotplug: introduce new function arch_remove_memory()
References: <50126B83.3050201@cn.fujitsu.com>	<50126E2F.8010301@cn.fujitsu.com>	<20120730102305.GB3631@osiris.boeblingen.de.ibm.com>	<50166379.4090305@cn.fujitsu.com> <20120731144000.33fd4a0a@thinkpad>
In-Reply-To: <20120731144000.33fd4a0a@thinkpad>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gerald.schaefer@de.ibm.com
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, Yasuaki ISIMATU <isimatu.yasuaki@jp.fujitsu.com>

At 07/31/2012 08:40 PM, Gerald Schaefer Wrote:
> On Mon, 30 Jul 2012 18:35:37 +0800
> Wen Congyang <wency@cn.fujitsu.com> wrote:
>=20
>> At 07/30/2012 06:23 PM, Heiko Carstens Wrote:
>>> On Fri, Jul 27, 2012 at 06:32:15PM +0800, Wen Congyang wrote:
>>>> We don't call =5F=5Fadd=5Fpages() directly in the function add=5Fmemor=
y()
>>>> because some other architecture related things need to be done
>>>> before or after calling =5F=5Fadd=5Fpages(). So we should introduce
>>>> a new function arch=5Fremove=5Fmemory() to revert the things
>>>> done in arch=5Fadd=5Fmemory().
>>>>
>>>> Note: the function for s390 is not implemented(I don't know how to
>>>> implement it for s390).
>>>
>>> There is no hardware or firmware interface which could trigger a
>>> hot memory remove on s390. So there is nothing that needs to be
>>> implemented.
>>
>> Thanks for providing this information.
>>
>> According to this, arch=5Fremove=5Fmemory() for s390 can just return
>> -EBUSY.
>=20
> Yes, but there is a prototype mismatch for arch=5Fremove=5Fmemory() on s3=
90
> and also other architectures (u64 vs. unsigned long).
>=20
> arch/s390/mm/init.c:262: error: conflicting types for
> =E2=80=98arch=5Fremove=5Fmemory=E2=80=99 include/linux/memory=5Fhotplug.h=
:88: error: previous
> declaration of =E2=80=98arch=5Fremove=5Fmemory=E2=80=99 was here
>=20
> In memory=5Fhotplug.h you have:
> extern int arch=5Fremove=5Fmemory(unsigned long start, unsigned long size=
);
>=20
> On all archs other than x86 you have:
> int arch=5Fremove=5Fmemory(u64 start, u64 size)

Thanks for pointing it out. I will fix it.

Wen Congyang

>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>=20

=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
