Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id B60F86B04A8
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 18:35:57 -0500 (EST)
Received: by mail-oi1-f199.google.com with SMTP id k17-v6so9657523oic.7
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 15:35:57 -0800 (PST)
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id o5si22988091ota.285.2018.11.06.15.35.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Nov 2018 15:35:56 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm/hotplug: Optimize clear_hwpoisoned_pages
Date: Tue, 6 Nov 2018 23:32:08 +0000
Message-ID: <20181106233207.GA10086@hori1.linux.bs1.fc.nec.co.jp>
References: <20181102120001.4526-1-bsingharora@gmail.com>
In-Reply-To: <20181102120001.4526-1-bsingharora@gmail.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <915B1044C3DC1F46A94DA8D832A6F625@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mhocko@suse.com" <mhocko@suse.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, Nov 02, 2018 at 11:00:01PM +1100, Balbir Singh wrote:
> In hot remove, we try to clear poisoned pages, but
> a small optimization to check if num_poisoned_pages
> is 0 helps remove the iteration through nr_pages.
>=20
> Signed-off-by: Balbir Singh <bsingharora@gmail.com>

Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Thanks!=
