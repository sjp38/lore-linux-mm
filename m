Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id A37B66B0003
	for <linux-mm@kvack.org>; Sat, 17 Feb 2018 11:07:30 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id r5so5277506qkb.22
        for <linux-mm@kvack.org>; Sat, 17 Feb 2018 08:07:30 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id d10si60528qth.432.2018.02.17.08.07.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 17 Feb 2018 08:07:29 -0800 (PST)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w1HG4YWE045423
	for <linux-mm@kvack.org>; Sat, 17 Feb 2018 11:07:29 -0500
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2g6ewb4p71-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 17 Feb 2018 11:07:28 -0500
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Sat, 17 Feb 2018 16:07:27 -0000
Date: Sat, 17 Feb 2018 17:07:16 +0100
In-Reply-To: <b76028c6-c755-8178-2dfc-81c7db1f8bed@infradead.org>
References: <20180216160110.641666320@linux.com> <20180216160121.519788537@linux.com> <b76028c6-c755-8178-2dfc-81c7db1f8bed@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Subject: Re: [RFC 1/2] Protect larger order pages from breaking up
From: Mike Rapoprt <rppt@linux.vnet.ibm.com>
Message-Id: <CF0D4656-676E-42EA-BB20-C3A557A397C6@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>, Christoph Lameter <cl@linux.com>, Mel Gorman <mel@skynet.ie>
Cc: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-rdma@vger.kernel.org, akpm@linux-foundation.org, Thomas Schoebel-Theuer <tst@schoebel-theuer.de>, andi@firstfloor.org, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@kernel.org>, Guy Shattah <sguy@mellanox.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Michal Nazarewicz <mina86@mina86.com>, Vlastimil Babka <vbabka@suse.cz>, David Nellans <dnellans@nvidia.com>, Laura Abbott <labbott@redhat.com>, Pavel Machek <pavel@ucw.cz>, Dave Hansen <dave.hansen@intel.com>, Mike Kravetz <mike.kravetz@oracle.com>



On February 16, 2018 7:02:53 PM GMT+01:00, Randy Dunlap <rdunlap@infradead=
=2Eorg> wrote:
>On 02/16/2018 08:01 AM, Christoph Lameter wrote:
>> Control over this feature is by writing to /proc/zoneinfo=2E
>>=20
>> F=2Ee=2E to ensure that 2000 16K pages stay available for jumbo
>> frames do
>>=20
>> 	echo "2=3D2000" >/proc/zoneinfo
>>=20
>> or through the order=3D<page spec> on the kernel command line=2E
>> F=2Ee=2E
>>=20
>> 	order=3D2=3D2000,4N2=3D500
>
>
>Please document the the kernel command line option in
>Documentation/admin-guide/kernel-parameters=2Etxt=2E
>
>I suppose that /proc/zoneinfo should be added somewhere in
>Documentation/vm/
>but I'm not sure where that would be=2E

It's in Documentation/sysctl/vm=2Etxt and in 'man proc' [1]

[1] https://git=2Ekernel=2Eorg/pub/scm/docs/man-pages/man-pages=2Egit/tree=
/man5/proc=2E5

>thanks,

--=20
Sincerely yours,
Mike=2E

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
