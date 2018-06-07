Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1263C6B0003
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 04:58:43 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id l11-v6so5939258oth.1
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 01:58:43 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e11-v6sor9898165oib.39.2018.06.07.01.58.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Jun 2018 01:58:41 -0700 (PDT)
MIME-Version: 1.0
References: <20180418193220.4603-1-timofey.titovets@synesis.ru>
 <20180418193220.4603-3-timofey.titovets@synesis.ru> <20180522202242.otvdunkl75yfhkt4@xakep.localdomain>
 <CAGqmi76gJV=ZDX5=Y3toF2tPiJs8T=PiUJFQg5nq9O5yztx80Q@mail.gmail.com>
 <CAGM2reaZ2YoxFhEDtcXi=hMFoGFi8+SROOn+_SRMwnx3cW15kw@mail.gmail.com>
 <CAGqmi76-qK9q_OTvyqpb-9k_m0CLMt3o860uaN5LL8nBkf5RTg@mail.gmail.com>
 <20180527130325.GB4522@rapoport-lnx> <CAGM2rea2GBvOAiKcSpHkQ9F+jgvy3sCsBw7hFz26DvQ+c_677A@mail.gmail.com>
In-Reply-To: <CAGM2rea2GBvOAiKcSpHkQ9F+jgvy3sCsBw7hFz26DvQ+c_677A@mail.gmail.com>
From: Timofey Titovets <nefelim4ag@gmail.com>
Date: Thu, 7 Jun 2018 11:58:05 +0300
Message-ID: <CAGqmi74G-7bM5mbbaHjzOkTvuEpCcAbZ8Q0PVCMkyP09XaVSkA@mail.gmail.com>
Subject: Re: [PATCH V6 2/2 RESEND] ksm: replace jhash2 with faster hash
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: pasha.tatashin@oracle.com
Cc: rppt@linux.vnet.ibm.com, linux-mm@kvack.org, Sioh Lee <solee@os.korea.ac.kr>, Andrea Arcangeli <aarcange@redhat.com>, kvm@vger.kernel.org

=D0=B2=D1=82, 29 =D0=BC=D0=B0=D1=8F 2018 =D0=B3. =D0=B2 17:46, Pavel Tatash=
in <pasha.tatashin@oracle.com>:
>
> > What about moving choice_fastest_hash() to run_store()?
>
> > KSM anyway starts with ksm_run =3D KSM_RUN_STOP and does not scan until
> > userspace writes !0 to /sys/kernel/mm/ksm/run.
>
> > Selection of the hash function when KSM is actually enabled seems quite
> > appropriate...
>
> Hi Mike,
>
> This is a good idea to select hash function from run_store() when (flags =
&
> KSM_RUN_MERGE) is set for the first time.
>
> Pavel

IIRC, run_store hidden under '#ifdef CONFIG_SYSFS'
So, what's about case without CONFIG_SYSFS?

--=20
Have a nice day,
Timofey.
