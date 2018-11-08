Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0ED706B0642
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 15:12:49 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id z7-v6so12028875edh.19
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 12:12:49 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id f24-v6si3013970edr.169.2018.11.08.12.12.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Nov 2018 12:12:47 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wA8K9B6x021519
	for <linux-mm@kvack.org>; Thu, 8 Nov 2018 15:12:46 -0500
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2nmrq9gvcq-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 08 Nov 2018 15:12:46 -0500
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Thu, 8 Nov 2018 20:12:44 -0000
Date: Thu, 8 Nov 2018 12:12:31 -0800
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: pkeys: Reserve PKEY_DISABLE_READ
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <877ehnbwqy.fsf@oldenburg.str.redhat.com>
 <2d62c9e2-375b-2791-32ce-fdaa7e7664fd@intel.com>
 <87bm6zaa04.fsf@oldenburg.str.redhat.com>
 <6f9c65fb-ea7e-8217-a4cc-f93e766ed9bb@intel.com>
 <87k1ln8o7u.fsf@oldenburg.str.redhat.com>
MIME-Version: 1.0
In-Reply-To: <87k1ln8o7u.fsf@oldenburg.str.redhat.com>
Message-Id: <20181108201231.GE5481@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-api@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

On Thu, Nov 08, 2018 at 06:37:41PM +0100, Florian Weimer wrote:
> * Dave Hansen:
>=20
> > On 11/8/18 7:01 AM, Florian Weimer wrote:
> >> Ideally, PKEY_DISABLE_READ | PKEY_DISABLE_WRITE and PKEY_DISABLE_READ |
> >> PKEY_DISABLE_ACCESS would be treated as PKEY_DISABLE_ACCESS both, and a
> >> line PKEY_DISABLE_READ would result in an EINVAL failure.
> >
> > Sounds reasonable to me.
> >
> > I don't see any urgency to do this right now.  It could easily go in
> > alongside the ppc patches when those get merged.
>=20
> POWER support has already been merged, so we need to do something here
> now, before I can complete the userspace side.
>=20
> > The only thing I'd suggest is that we make it something slightly
> > higher than 0x4.  It'll make the code easier to deal with in the
> > kernel if we have the ABI and the hardware mirror each other, and if
> > we pick 0x4 in the ABI for PKEY_DISABLE_READ, it might get messy if
> > the harware choose 0x4 for PKEY_DISABLE_EXECUTE or something.
> >=20
> > So, let's make it 0x80 or something on x86 at least.
>=20
> I don't have a problem with that if that's what it takes.
>=20
> > Also, I'll be happy to review and ack the patch to do this, but I'd
> > expect the ppc guys (hi Ram!) to actually put it together.
>=20
> Ram, do you want to write a patch?


Florian,

	I can. But I am struggling to understand the requirement. Why is
	this needed?  Are we proposing a enhancement to the sys_pkey_alloc(),
	to be able to allocate keys that are initialied to disable-read
	only?

RP

>=20
> I'll promise I finish the glibc support for this. 8-)
>=20
> Thanks,
> Florian

--=20
Ram Pai
