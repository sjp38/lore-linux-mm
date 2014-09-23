Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id DA0BA6B0035
	for <linux-mm@kvack.org>; Tue, 23 Sep 2014 16:13:31 -0400 (EDT)
Received: by mail-la0-f47.google.com with SMTP id mc6so9560032lab.34
        for <linux-mm@kvack.org>; Tue, 23 Sep 2014 13:13:30 -0700 (PDT)
Received: from mail-lb0-x22e.google.com (mail-lb0-x22e.google.com [2a00:1450:4010:c04::22e])
        by mx.google.com with ESMTPS id am7si20112183lac.74.2014.09.23.13.13.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 23 Sep 2014 13:13:30 -0700 (PDT)
Received: by mail-lb0-f174.google.com with SMTP id l4so9324046lbv.5
        for <linux-mm@kvack.org>; Tue, 23 Sep 2014 13:13:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140923130128.79f5931ac03dbb31f53be805@linux-foundation.org>
References: <5420b8b0.9HdYLyyuTikszzH8%akpm@linux-foundation.org>
	<20140923190222.GA4662@roeck-us.net>
	<20140923130128.79f5931ac03dbb31f53be805@linux-foundation.org>
Date: Tue, 23 Sep 2014 17:13:29 -0300
Message-ID: <CAOMZO5CdVenLgOFvPXpQB9f1H_ATayDDk5e9Rhrf-32OweqO2w@mail.gmail.com>
Subject: Re: mmotm 2014-09-22-16-57 uploaded
From: Fabio Estevam <festevam@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Guenter Roeck <linux@roeck-us.net>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>, mhocko@suse.cz, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Sasha Levin <sasha.levin@oracle.com>, Anish Bhatt <anish@chelsio.com>, David Miller <davem@davemloft.net>, Fabio Estevam <fabio.estevam@freescale.com>

On Tue, Sep 23, 2014 at 5:01 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:

>> arm:imx_v6_v7_defconfig
>> arm:imx_v4_v5_defconfig
>>
>> drivers/media/platform/coda/coda-bit.c: In function 'coda_fill_bitstream':
>> drivers/media/platform/coda/coda-bit.c:231:4: error: implicit declaration of function 'kmalloc'
>> drivers/media/platform/coda/coda-bit.c: In function 'coda_alloc_framebuffers':
>> drivers/media/platform/coda/coda-bit.c:312:3: error: implicit declaration of function 'kfree'
>
> That's odd - it includes slab.h.  Cc Fabio.

linux-next 20140923 has commit c0aaf696d45e2a72 which included slab.h
and fixed these errors.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
