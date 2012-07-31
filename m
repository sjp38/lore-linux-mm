Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id B3A0A6B004D
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 08:40:07 -0400 (EDT)
Received: from /spool/local
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Tue, 31 Jul 2012 13:40:06 +0100
Received: from d06av05.portsmouth.uk.ibm.com (d06av05.portsmouth.uk.ibm.com [9.149.37.229])
	by d06nrmr1806.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6VCe4sm2969604
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 13:40:04 +0100
Received: from d06av05.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av05.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6VCe3cP001509
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 06:40:04 -0600
Date: Tue, 31 Jul 2012 14:40:00 +0200
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: Re: [RFC PATCH v5 12/19] memory-hotplug: introduce new function
 arch_remove_memory()
Message-ID: <20120731144000.33fd4a0a@thinkpad>
In-Reply-To: <50166379.4090305@cn.fujitsu.com>
References: <50126B83.3050201@cn.fujitsu.com>
	<50126E2F.8010301@cn.fujitsu.com>
	<20120730102305.GB3631@osiris.boeblingen.de.ibm.com>
	<50166379.4090305@cn.fujitsu.com>
Reply-To: gerald.schaefer@de.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wen Congyang <wency@cn.fujitsu.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, Yasuaki ISIMATU <isimatu.yasuaki@jp.fujitsu.com>

On Mon, 30 Jul 2012 18:35:37 +0800
Wen Congyang <wency@cn.fujitsu.com> wrote:

> At 07/30/2012 06:23 PM, Heiko Carstens Wrote:
> > On Fri, Jul 27, 2012 at 06:32:15PM +0800, Wen Congyang wrote:
> >> We don't call __add_pages() directly in the function add_memory()
> >> because some other architecture related things need to be done
> >> before or after calling __add_pages(). So we should introduce
> >> a new function arch_remove_memory() to revert the things
> >> done in arch_add_memory().
> >>
> >> Note: the function for s390 is not implemented(I don't know how to
> >> implement it for s390).
> >=20
> > There is no hardware or firmware interface which could trigger a
> > hot memory remove on s390. So there is nothing that needs to be
> > implemented.
>=20
> Thanks for providing this information.
>=20
> According to this, arch_remove_memory() for s390 can just return
> -EBUSY.

Yes, but there is a prototype mismatch for arch_remove_memory() on s390
and also other architectures (u64 vs. unsigned long).

arch/s390/mm/init.c:262: error: conflicting types for
=E2=80=98arch_remove_memory=E2=80=99 include/linux/memory_hotplug.h:88: err=
or: previous
declaration of =E2=80=98arch_remove_memory=E2=80=99 was here

In memory_hotplug.h you have:
extern int arch_remove_memory(unsigned long start, unsigned long size);

On all archs other than x86 you have:
int arch_remove_memory(u64 start, u64 size)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
