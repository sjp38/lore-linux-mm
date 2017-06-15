Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 180996B0279
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 00:28:54 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id m5so3107198pgn.1
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 21:28:54 -0700 (PDT)
Received: from mail-pg0-x22d.google.com (mail-pg0-x22d.google.com. [2607:f8b0:400e:c05::22d])
        by mx.google.com with ESMTPS id e63si1384871plb.245.2017.06.14.21.28.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Jun 2017 21:28:53 -0700 (PDT)
Received: by mail-pg0-x22d.google.com with SMTP id k71so2090684pgd.2
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 21:28:51 -0700 (PDT)
Date: Thu, 15 Jun 2017 14:28:42 +1000
From: Balbir Singh <bsingharora@gmail.com>
Subject: Re: [HMM-CDM 2/5] mm/hmm: add new helper to hotplug CDM memory
 region
Message-ID: <20170615142842.22393df9@firefly.ozlabs.ibm.com>
In-Reply-To: <20170614201144.9306-3-jglisse@redhat.com>
References: <20170614201144.9306-1-jglisse@redhat.com>
	<20170614201144.9306-3-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>

On Wed, 14 Jun 2017 16:11:41 -0400
J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com> wrote:

> Unlike unaddressable memory, coherent device memory has a real
> resource associated with it on the system (as CPU can address
> it). Add a new helper to hotplug such memory within the HMM
> framework.
>=20
> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> ---

Looks good to me

Reviewed-by: Balbir Singh <bsingharora@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
