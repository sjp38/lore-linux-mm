Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 91A496B0005
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 01:42:16 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id pp5so282241892pac.3
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 22:42:16 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id s4si1257851pax.44.2016.08.01.22.42.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 01 Aug 2016 22:42:14 -0700 (PDT)
Subject: Re: [PATCH] mm/memblock.c: fix NULL dereference error
References: <57A029A9.6060303@zoho.com>
From: zijun_hu <zijun_hu@zoho.com>
Message-ID: <57A0320D.6070102@zoho.com>
Date: Tue, 2 Aug 2016 13:39:25 +0800
MIME-Version: 1.0
In-Reply-To: <57A029A9.6060303@zoho.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: ard.biesheuvel@linaro.org, david@gibson.dropbear.id.au, dev@g0hl1n.net, kuleshovmail@gmail.com, tangchen@cn.fujitsu.com, tj@kernel.org, weiyang@linux.vnet.ibm.com, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org

Hi All,

this mail correct the following mistakes in last mail
1, remove test patch attached 
2, format patch to satisfy rules
i am so sorry for my mistake

Hi Andrew,

this patch is part of https://lkml.org/lkml/2016/7/26/347 and isn't merged in
as you advised in another mail, i release this patch against linus's mainline
for fixing relevant bugs completely
