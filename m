Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id B6E546B0003
	for <linux-mm@kvack.org>; Mon, 14 May 2018 11:33:00 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id k14-v6so4966926pgr.18
        for <linux-mm@kvack.org>; Mon, 14 May 2018 08:33:00 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id t14-v6sor5789595pfa.143.2018.05.14.08.32.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 14 May 2018 08:32:57 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH] pkeys: Introduce PKEY_ALLOC_SIGNALINHERIT and change signal semantics
From: Andy Lutomirski <luto@amacapital.net>
In-Reply-To: <008010c1-20a1-c307-25ac-8a69d672d031@redhat.com>
Date: Mon, 14 May 2018 08:32:54 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <E77C6E12-EF2A-435A-AAD4-1554459606F1@amacapital.net>
References: <20180502132751.05B9F401F3041@oldenburg.str.redhat.com> <248faadb-e484-806f-1485-c34a72a9ca0b@intel.com> <822a28c9-5405-68c2-11bf-0c282887466d@redhat.com> <57459C6F-C8BA-4E2D-99BA-64F35C11FC05@amacapital.net> <6286ba0a-7e09-b4ec-e31f-bd091f5940ff@redhat.com> <CALCETrVrm6yGiv6_z7RqdeB-324RoeMmjpf1EHsrGOh+iKb7+A@mail.gmail.com> <b2df1386-9df9-2db8-0a25-51bf5ff63592@redhat.com> <CALCETrW_Dt-HoG4keFJd8DSD=tvyR+bBCFrBDYdym4GQbfng4A@mail.gmail.com> <20180503021058.GA5670@ram.oc3035372033.ibm.com> <CALCETrXRQF08exQVZqtTLOKbC8Ywq5x4EYH_1D7r5v9bdOSwbg@mail.gmail.com> <927c8325-4c98-d7af-b921-6aafcf8fe992@redhat.com> <CALCETrX46wR_MDW=m9SVm=ejQmPAmD3+2oC3iapf75bPhnEAWQ@mail.gmail.com> <314e1a48-db94-9b37-8793-a95a2082c9e2@redhat.com> <CALCETrUGjN8mhOaLqGcau-pPKm9TQW8k05hZrh52prRNdC5yQQ@mail.gmail.com> <008010c1-20a1-c307-25ac-8a69d672d031@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>
Cc: Andy Lutomirski <luto@kernel.org>, linuxram@us.ibm.com, Dave Hansen <dave.hansen@intel.com>, Linux-MM <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, linux-x86_64@vger.kernel.org, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>




> On May 14, 2018, at 5:01 AM, Florian Weimer <fweimer@redhat.com> wrote:
>=20
>> One thing we could do, though: the current initual state on process
>> creation is all access blocked on all keys.  We could change it so that
>> half the keys are fully blocked and half are read-only.  Then we could ad=
d
>> a PKEY_ALLOC_STRICT or similar that allocates a key with the correct
>> initial state*and*  does the setsignal thing.  If there are no keys left
>> with the correct initial state, then it fails.
>=20
> The initial PKRU value can currently be configured by the system administr=
ator.  I fear this approach has too many moving parts to be viable.
>=20
>=20

Honestly, I think we should drop that option. I don=E2=80=99t see how we can=
 expect an administrator to do this usefully.=
