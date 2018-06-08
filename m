Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6E2696B0003
	for <linux-mm@kvack.org>; Fri,  8 Jun 2018 08:54:19 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id s3-v6so5932499plp.21
        for <linux-mm@kvack.org>; Fri, 08 Jun 2018 05:54:19 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b30-v6si19885667pli.427.2018.06.08.05.54.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 08 Jun 2018 05:54:18 -0700 (PDT)
Date: Fri, 8 Jun 2018 14:54:13 +0200
From: Michal =?UTF-8?B?U3VjaMOhbmVr?= <msuchanek@suse.de>
Subject: Re: pkeys on POWER: Access rights not reset on execve
Message-ID: <20180608145413.393fa245@kitsune.suse.cz>
In-Reply-To: <aa136e1e-3bf2-fd92-2eab-16469c467729@redhat.com>
References: <20180520060425.GL5479@ram.oc3035372033.ibm.com>
	<CALCETrVvQkphypn10A_rkX35DNqi29MJcXYRpRiCFNm02VYz2g@mail.gmail.com>
	<20180520191115.GM5479@ram.oc3035372033.ibm.com>
	<aae1952c-886b-cfc8-e98b-fa3be5fab0fa@redhat.com>
	<20180603201832.GA10109@ram.oc3035372033.ibm.com>
	<4e53b91f-80a7-816a-3e9b-56d7be7cd092@redhat.com>
	<20180604140135.GA10088@ram.oc3035372033.ibm.com>
	<f2f61c24-8e8f-0d36-4e22-196a2a3f7ca7@redhat.com>
	<20180604190229.GB10088@ram.oc3035372033.ibm.com>
	<30040030-1aa2-623b-beec-dd1ceb3eb9a7@redhat.com>
	<20180608023441.GA5573@ram.oc3035372033.ibm.com>
	<2858a8eb-c9b5-42ce-5cfc-74a4b3ad6aa9@redhat.com>
	<20180608121551.3c151e0c@naga.suse.cz>
	<aa136e1e-3bf2-fd92-2eab-16469c467729@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>
Cc: Linux-MM <linux-mm@kvack.org>, Ram Pai <linuxram@us.ibm.com>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>

On Fri, 8 Jun 2018 12:44:53 +0200
Florian Weimer <fweimer@redhat.com> wrote:

> On 06/08/2018 12:15 PM, Michal Such=C3=A1nek wrote:
> > On Fri, 8 Jun 2018 07:53:51 +0200
> > Florian Weimer <fweimer@redhat.com> wrote:
> >  =20
> >> On 06/08/2018 04:34 AM, Ram Pai wrote: =20
> >>>>
> >>>> So the remaining question at this point is whether the Intel
> >>>> behavior (default-deny instead of default-allow) is preferable. =20
> >>>
> >>> Florian, remind me what behavior needs to fixed? =20
> >>
> >> See the other thread.  The Intel register equivalent to the AMR by
> >> default disallows access to yet-unallocated keys, so that threads
> >> which are created before key allocation do not magically gain
> >> access to a key allocated by another thread.
> >> =20
> >=20
> > That does not make any sense. The threads share the address space so
> > they should also share the keys.
> >=20
> > Or in other words the keys are supposed to be acceleration of
> > mprotect() so if mprotect() magically gives access to threads that
> > did not call it so should pkey functions. If they cannot do that
> > then they fail the primary purpose. =20
>=20
> That's not how protection keys work.  The access rights are=20
> thread-specific, so that you can change them locally, without=20
> synchronization and expensive inter-node communication.
>=20

And the association of a key with part of the address space is
thread-local as well?

Thanks

Michal
