Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 61C106B0003
	for <linux-mm@kvack.org>; Mon,  4 Jun 2018 07:28:02 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id v4-v6so3236468iol.8
        for <linux-mm@kvack.org>; Mon, 04 Jun 2018 04:28:02 -0700 (PDT)
Received: from huawei.com (szxga03-in.huawei.com. [45.249.212.189])
        by mx.google.com with ESMTPS id 195-v6si5502148ioe.30.2018.06.04.04.28.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jun 2018 04:28:01 -0700 (PDT)
From: Nixiaoming <nixiaoming@huawei.com>
Subject: RE: [PATCH] mm: Add conditions to avoid out-of-bounds
Date: Mon, 4 Jun 2018 11:27:26 +0000
Message-ID: <E490CD805F7529488761C40FD9D26EF12A6834EF@dggemm507-mbx.china.huawei.com>
References: <20180604103735.42781-1-nixiaoming@huawei.com>
 <20180604112026.GI19202@dhcp22.suse.cz>
In-Reply-To: <20180604112026.GI19202@dhcp22.suse.cz>
Content-Language: zh-CN
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "vdavydov.dev@gmail.com" <vdavydov.dev@gmail.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "garsilva@embeddedor.com" <garsilva@embeddedor.com>, "ktkhai@virtuozzo.com" <ktkhai@virtuozzo.com>, "stummala@codeaurora.org" <stummala@codeaurora.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

I'm very sorry. It was my mistake.=20
it won't cross the border here.

Thanks=20


-----Original Message-----
From: Michal Hocko [mailto:mhocko@kernel.org]=20
Sent: Monday, June 04, 2018 7:20 PM
To: Nixiaoming <nixiaoming@huawei.com>
Cc: akpm@linux-foundation.org; vdavydov.dev@gmail.com; hannes@cmpxchg.org; =
garsilva@embeddedor.com; ktkhai@virtuozzo.com; stummala@codeaurora.org; lin=
ux-kernel@vger.kernel.org; linux-mm@kvack.org
Subject: Re: [PATCH] mm: Add conditions to avoid out-of-bounds

On Mon 04-06-18 18:37:35, nixiaoming wrote:
> In the function memcg_init_list_lru
> if call goto fail when i =3D=3D 0, will cause out-of-bounds at lru->node[=
i]

How? All I can see is that the fail path does
	for (i =3D i - 1; i >=3D 0; i--)

so it will not do anything for i=3D0.
--=20
Michal Hocko
SUSE Labs
