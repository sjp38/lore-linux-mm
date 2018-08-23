Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 555A46B29CE
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 07:21:59 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id q26-v6so1629186wmc.0
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 04:21:59 -0700 (PDT)
Received: from eu-smtp-delivery-211.mimecast.com (eu-smtp-delivery-211.mimecast.com. [146.101.78.211])
        by mx.google.com with ESMTPS id 93-v6si3808739wrq.89.2018.08.23.04.21.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Aug 2018 04:21:58 -0700 (PDT)
From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] fs: fix local var type
Date: Thu, 23 Aug 2018 11:23:35 +0000
Message-ID: <b66e21d0f55b4f568c81bb9d5d22b7a7@AcuMS.aculab.com>
References: <1535014754-31918-1-git-send-email-swkhack@gmail.com>
 <20180823111355.GD29735@dhcp22.suse.cz>
In-Reply-To: <20180823111355.GD29735@dhcp22.suse.cz>
Content-Language: en-US
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Michal Hocko' <mhocko@kernel.org>, Weikang Shi <swkhack@gmail.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "alexander.h.duyck@intel.com" <alexander.h.duyck@intel.com>, "vbabka@suse.cz" <vbabka@suse.cz>, "mgorman@suse.de" <mgorman@suse.de>, "l.stach@pengutronix.de" <l.stach@pengutronix.de>, "vdavydov.dev@gmail.com" <vdavydov.dev@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "my_email@gmail.com" <my_email@gmail.com>

From: Michal Hocko
> Sent: 23 August 2018 12:14
>=20
> On Thu 23-08-18 01:59:14, Weikang Shi wrote:
> > In the seq_hex_dump function,the remaining variable is int, but it rece=
ive a type of size_t
> argument.
> > So I change the type of remaining
>=20
> The changelog should explain _why_ we need this fix. Is any of the code
> path overflowing?
>=20
> Besides that I do not think this fix is complete. What about linelen?
>=20
> Why do we even need len to be size_t? Why it cannot be int as well. I
> strongly doubt we need more than 32b here.

Although you may well want 'unsigned int' to avoid the sign extension
instruction that gets added for x86_64 when a signed int is added
to a pointer.

=09David

-
Registered Address Lakeside, Bramley Road, Mount Farm, Milton Keynes, MK1 1=
PT, UK
Registration No: 1397386 (Wales)
