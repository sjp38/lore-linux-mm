Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6E03A6B0003
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 13:24:05 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id w17so6459812qkb.19
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 10:24:05 -0700 (PDT)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id i9si943655qte.309.2018.04.09.10.24.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Apr 2018 10:24:04 -0700 (PDT)
Subject: Re: [PATCH] Documentation/vm/hmm.txt: typos and syntaxes fixes
References: <20180409151859.4713-1-jglisse@redhat.com>
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <680b24d9-1c6b-a16c-45f3-6fd7a31c3840@nvidia.com>
Date: Mon, 9 Apr 2018 10:24:03 -0700
MIME-Version: 1.0
In-Reply-To: <20180409151859.4713-1-jglisse@redhat.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Randy Dunlap <rdunlap@infradead.org>


On 04/09/2018 08:18 AM, jglisse@redhat.com wrote:
> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>=20
> This fix typos and syntaxes, thanks to Randy Dunlap for pointing them
> out (they were all my faults).
>=20
> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Cc: Randy Dunlap <rdunlap@infradead.org>
> Cc: Ralph Campbell <rcampbell@nvidia.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> ---

You can add:

Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
