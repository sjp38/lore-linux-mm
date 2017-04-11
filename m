Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8A8686B0390
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 21:33:56 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id q54so32329691qta.7
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 18:33:56 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 6si3466995qke.125.2017.04.10.18.33.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Apr 2017 18:33:55 -0700 (PDT)
Date: Mon, 10 Apr 2017 21:33:51 -0400 (EDT)
From: Jerome Glisse <jglisse@redhat.com>
Message-ID: <536509398.25054000.1491874431882.JavaMail.zimbra@redhat.com>
In-Reply-To: <20170410151031.d9488d850d740e894a55321c@linux-foundation.org>
References: <20170405204026.3940-1-jglisse@redhat.com> <20170405204026.3940-11-jglisse@redhat.com> <20170410084326.GB4625@dhcp22.suse.cz> <20170410151031.d9488d850d740e894a55321c@linux-foundation.org>
Subject: Re: [HMM 10/16] mm/hmm/mirror: helper to snapshot CPU page table v2
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

> On Mon, 10 Apr 2017 10:43:26 +0200 Michal Hocko <mhocko@kernel.org> wrote=
:
>=20
> > There are more for alpha allmodconfig
>=20
> HMM is rather a compile catastrophe, as was the earlier version I
> merged.
>=20
> Jerome, I'm thinking you need to install some cross-compilers!

Sorry about that.

I tested some but obviously not all, in the v20 i did on top of Michal
patchset i simply made everything to be x86-64 only. So if you revert
v19 and wait for Michal to finish his v3 then i will post v20 that is
x86-64 only which i do build and use. At least from my discussion with
Michal i thought you were dropping v19 until Michal could finish his
memory hotplug rework.

Cheers,
J=C3=A9r=C3=B4me

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
