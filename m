Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 56C406B004F
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 14:48:26 -0400 (EDT)
Received: from spaceape11.eur.corp.google.com (spaceape11.eur.corp.google.com [172.28.16.145])
	by smtp-out.google.com with ESMTP id n5IIntEW028580
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 19:49:55 +0100
Received: from pzk30 (pzk30.prod.google.com [10.243.19.158])
	by spaceape11.eur.corp.google.com with ESMTP id n5IInqce014028
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 11:49:53 -0700
Received: by pzk30 with SMTP id 30so1144414pzk.18
        for <linux-mm@kvack.org>; Thu, 18 Jun 2009 11:49:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090616135315.25248.7893.sendpatchset@lts-notebook>
References: <20090616135228.25248.22018.sendpatchset@lts-notebook>
	 <20090616135315.25248.7893.sendpatchset@lts-notebook>
Date: Thu, 18 Jun 2009 11:49:51 -0700
Message-ID: <9ec263480906181149t1aac592o57ce517bdd749cf5@mail.gmail.com>
Subject: Re: [PATCH 5/5] Update huge pages kernel documentation
From: David Rientjes <rientjes@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Tue, Jun 16, 2009 at 6:53 AM, Lee
Schermerhorn<lee.schermerhorn@hp.com> wrote:
> @@ -67,26 +65,76 @@ use either the mmap system call or share
> =C2=A0the huge pages. =C2=A0It is required that the system administrator =
preallocate
> =C2=A0enough memory for huge page purposes.
>
> -Use the following command to dynamically allocate/deallocate hugepages:
> +The administrator can preallocate huge pages on the kernel boot command =
line by
> +specifying the "hugepages=3DN" parameter, where 'N' =3D the number of hu=
ge pages
> +requested. =C2=A0This is the most reliable method for preallocating huge=
 pages as
> +memory has not yet become fragmented.
> +
> +Some platforms support multiple huge page sizes. =C2=A0To preallocate hu=
ge pages
> +of a specific size, one must preceed the huge pages boot command paramet=
ers
> +with a huge page size selection parameter "hugepagesz=3D<size>". =C2=A0<=
size> must
> +be specified in bytes with optional scale suffix [kKmMgG]. =C2=A0The def=
ault huge
> +page size may be selected with the "default_hugepagesz=3D<size>" boot pa=
rameter.
> +
> +/proc/sys/vm/nr_hugepages indicates the current number of configured [de=
fault
> +size] hugetlb pages in the kernel. =C2=A0Super user can dynamically requ=
est more
> +(or free some pre-configured) hugepages.
> +
> +Use the following command to dynamically allocate/deallocate default siz=
ed
> +hugepages:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0echo 20 > /proc/sys/vm/nr_hugepages
>
> -This command will try to configure 20 hugepages in the system. =C2=A0The=
 success
> -or failure of allocation depends on the amount of physically contiguous
> -memory that is preset in system at this time. =C2=A0System administrator=
s may want
> -to put this command in one of the local rc init files. =C2=A0This will e=
nable the
> -kernel to request huge pages early in the boot process (when the possibi=
lity
> -of getting physical contiguous pages is still very high). In either
> -case, administrators will want to verify the number of hugepages actuall=
y
> -allocated by checking the sysctl or meminfo.
> +This command will try to configure 20 default sized hugepages in the sys=
tem.
> +On a NUMA platform, the kernel will attempt to distribute the hugepage p=
ool
> +over the nodes specified by the /proc/sys/vm/hugepages_nodes_allowed nod=
e mask.
> +hugepages_nodes_allowed defaults to all on-line nodes.
> +
> +To control the nodes on which huge pages are preallocated, the administr=
ator
> +may set the hugepages_nodes_allowed for the default huge page size using=
:
> +
> + =C2=A0 =C2=A0 =C2=A0 echo <nodelist> >/proc/sys/vm/hugepages_nodes_allo=
wed
> +

This probably also needs an update to
Documentation/ABI/testing/sysfs-kernel-mm-hugepages for the
non-default hstate nodes_allowed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
