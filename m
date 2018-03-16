Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 242FB6B0009
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 07:02:25 -0400 (EDT)
Received: by mail-ua0-f199.google.com with SMTP id t34so6224632uat.3
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 04:02:25 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t80sor1070982vkb.21.2018.03.16.04.02.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 16 Mar 2018 04:02:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1521196416-18157-1-git-send-email-linuxram@us.ibm.com>
References: <1521196416-18157-1-git-send-email-linuxram@us.ibm.com>
From: Balbir Singh <bsingharora@gmail.com>
Date: Fri, 16 Mar 2018 22:02:22 +1100
Message-ID: <CAKTCnzmSCT+VecdSRpyY2Rb_AW2ngCi3UTZfLE3VOLNSQn6vsA@mail.gmail.com>
Subject: Re: [PATCH v4] mm, pkey: treat pkey-0 special
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>, Ingo Molnar <mingo@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "open list:LINUX FOR POWERPC (32-BIT AND 64-BIT)" <linuxppc-dev@lists.ozlabs.org>, linux-mm <linux-mm@kvack.org>, "maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)" <x86@kernel.org>, linux-arch <linux-arch@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dave Hansen <dave.hansen@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Aneesh Kumar KV <aneesh.kumar@linux.vnet.ibm.com>, Haren Myneni/Beaverton/IBM <hbabu@us.ibm.com>, Michal Hocko <mhocko@kernel.org>, Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Jonathan Corbet <corbet@lwn.net>, Arnd Bergmann <arnd@arndb.de>, fweimer@redhat.com, msuchanek@suse.com, Thomas Gleixner <tglx@linutronix.de>, Ulrich.Weigand@de.ibm.com, Ram Pai <ram.n.pai@gmail.com>

On Fri, Mar 16, 2018 at 9:33 PM, Ram Pai <linuxram@us.ibm.com> wrote:
> Applications need the ability to associate an address-range with some
> key and latter revert to its initial default key. Pkey-0 comes close to
> providing this function but falls short, because the current
> implementation disallows applications to explicitly associate pkey-0 to
> the address range.
>
> Clarify the semantics of pkey-0 and provide the corresponding
> implementation.
>
> Pkey-0 is special with the following semantics.
> (a) it is implicitly allocated and can never be freed. It always exists.
> (b) it is the default key assigned to any address-range.
> (c) it can be explicitly associated with any address-range.
>
> Tested on powerpc only. Could not test on x86.


Ram,

I was wondering if we should check the AMOR values on the ppc side to make sure
that pkey0 is indeed available for use as default. I am still of the
opinion that we
should consider non-0 default pkey in the long run. I'm OK with the patches for
now, but really 0 is not special except for it being the default bit
values present
in the PTE.

The patches themselves look OK to me

Balbir Singh.
