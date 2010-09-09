Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 76AD46B004A
	for <linux-mm@kvack.org>; Thu,  9 Sep 2010 11:16:04 -0400 (EDT)
Received: by qwf7 with SMTP id 7so655356qwf.14
        for <linux-mm@kvack.org>; Thu, 09 Sep 2010 08:15:41 -0700 (PDT)
MIME-Version: 1.0
Reply-To: sedat.dilek@gmail.com
In-Reply-To: <AANLkTi=uzLJxDbd+uJAww-b5aP10gd8gbGVG19HS46ue@mail.gmail.com>
References: <AANLkTi=uzLJxDbd+uJAww-b5aP10gd8gbGVG19HS46ue@mail.gmail.com>
Date: Thu, 9 Sep 2010 17:15:22 +0200
Message-ID: <AANLkTinoR=ZeCqcqSuoY884y_7MNB50B7RiwY4B+Fycc@mail.gmail.com>
Subject: Re: mm/Kconfig: warning: (COMPACTION && EXPERIMENTAL && HUGETLB_PAGE
 && MMU) selects MIGRATION which has unmet direct dependencies (NUMA || ARCH_ENABLE_MEMORY_HOTREMOVE)
From: Sedat Dilek <sedat.dilek@googlemail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Argh, forgot...

[ mm/Kconfig ]
...
#
# support for page migration
#
config MIGRATION
        bool "Page migration"
        def_bool y
        depends on NUMA || ARCH_ENABLE_MEMORY_HOTREMOVE
        help
          Allows the migration of the physical location of pages of process=
es
          while the virtual addresses are not changed. This is useful in
          two situations. The first is on NUMA systems to put pages nearer
          to the processors accessing. The second is when allocating huge
          pages as migration can relocate pages to satisfy a huge page
          allocation instead of reclaiming.
...

- Sedat -

On Thu, Sep 9, 2010 at 5:10 PM, Sedat Dilek <sedat.dilek@googlemail.com> wr=
ote:
> Hi,
>
> while build latest 2.6.36-rc3 I get this warning:
>
> [ build.log]
> ...
> warning: (COMPACTION && EXPERIMENTAL && HUGETLB_PAGE && MMU) selects
> MIGRATION which has unmet direct dependencies (NUMA ||
> ARCH_ENABLE_MEMORY_HOTREMOVE)
> ...
>
> Here the excerpt of...
>
> [ mm/Kconfig ]
> ...
> # support for memory compaction
> config COMPACTION
> =C2=A0 =C2=A0 =C2=A0 =C2=A0bool "Allow for memory compaction"
> =C2=A0 =C2=A0 =C2=A0 =C2=A0select MIGRATION
> =C2=A0 =C2=A0 =C2=A0 =C2=A0depends on EXPERIMENTAL && HUGETLB_PAGE && MMU
> =C2=A0 =C2=A0 =C2=A0 =C2=A0help
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Allows the compaction of memory for the=
 allocation of huge pages.
> ...
>
> I have set the following kernel-config parameters:
>
> $ egrep 'COMPACTION|HUGETLB_PAGE|MMU|MIGRATION|NUMA|ARCH_ENABLE_MEMORY_HO=
TREMOVE'
> linux-2.6.36-rc3/debian/build/build_i386_none_686/.config
> CONFIG_MMU=3Dy
> # CONFIG_IOMMU_HELPER is not set
> CONFIG_IOMMU_API=3Dy
> CONFIG_COMPACTION=3Dy
> CONFIG_MIGRATION=3Dy
> CONFIG_MMU_NOTIFIER=3Dy
> CONFIG_HUGETLB_PAGE=3Dy
> # CONFIG_IOMMU_STRESS is not set
>
> Looks like I have no NUMA or ARCH_ENABLE_MEMORY_HOTREMOVE set.
>
> Ok, it is a *warning*...
>
> Kind Regards,
> - Sedat -
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
