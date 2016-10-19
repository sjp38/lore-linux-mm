Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f199.google.com (mail-yb0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3893E6B0069
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 14:01:51 -0400 (EDT)
Received: by mail-yb0-f199.google.com with SMTP id f97so31200030ybi.7
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 11:01:51 -0700 (PDT)
Received: from mail-yw0-x242.google.com (mail-yw0-x242.google.com. [2607:f8b0:4002:c05::242])
        by mx.google.com with ESMTPS id i124si11647327ywc.27.2016.10.19.11.01.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Oct 2016 11:01:50 -0700 (PDT)
Received: by mail-yw0-x242.google.com with SMTP id e5so1086072ywc.3
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 11:01:50 -0700 (PDT)
Date: Wed, 19 Oct 2016 14:01:48 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/1] mm/percpu.c: append alignment sanity checkup to
 avoid memory leakage
Message-ID: <20161019180148.GG18532@htj.duckdns.org>
References: <58008576.3060302@zoho.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <58008576.3060302@zoho.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zijun_hu <zijun_hu@zoho.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, zijun_hu@htc.com, cl@linux.com

Hello,

I updated the patch description and code style a bit and applied to
percpu/for-4.10.

Thanks.

------ 8< ------
