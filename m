Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4B9726B0005
	for <linux-mm@kvack.org>; Fri,  9 Mar 2018 15:06:50 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id g13so7632954qtj.15
        for <linux-mm@kvack.org>; Fri, 09 Mar 2018 12:06:50 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id n1si1453630qkf.460.2018.03.09.12.06.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Mar 2018 12:06:49 -0800 (PST)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w29K0QYB122449
	for <linux-mm@kvack.org>; Fri, 9 Mar 2018 15:06:48 -0500
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2gkyfd3j8d-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 09 Mar 2018 15:06:48 -0500
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Fri, 9 Mar 2018 20:06:45 -0000
Date: Fri, 9 Mar 2018 12:06:31 -0800
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [PATCH] x86, powerpc : pkey-mprotect must allow pkey-0
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <1520583161-11741-1-git-send-email-linuxram@us.ibm.com>
 <87lgf1v9di.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <87lgf1v9di.fsf@concordia.ellerman.id.au>
Message-Id: <20180309200631.GS1060@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: mingo@redhat.com, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, corbet@lwn.net, arnd@arndb.de, fweimer@redhat.com, msuchanek@suse.com, Ulrich.Weigand@de.ibm.com

On Fri, Mar 09, 2018 at 09:19:53PM +1100, Michael Ellerman wrote:
> Ram Pai <linuxram@us.ibm.com> writes:
>=20
> > Once an address range is associated with an allocated pkey, it cannot be
> > reverted back to key-0. There is no valid reason for the above behavior=
=2E  On
> > the contrary applications need the ability to do so.
>=20
> Please explain this in much more detail. Is it an ABI change?

Not necessarily an ABI change. older binary applications  will continue
to work. It can be considered as a bug-fix.

>=20
> And why did we just notice this?

Yes. this was noticed by an application vendor.

>=20
> > The patch relaxes the restriction.
> >
> > Tested on powerpc and x86_64.
>=20
> Thanks, but please split the patch, one for each arch.

Will do.
RP
