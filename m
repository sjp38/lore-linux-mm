Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 23BF96B0253
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 04:02:58 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id ag5so395427865pad.2
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 01:02:58 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id zd5si13417409pac.155.2016.08.04.01.02.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 04 Aug 2016 01:02:57 -0700 (PDT)
From: zijun_hu <zijun_hu@zoho.com>
Subject: [PATCH] mm/vmalloc: fix align value calculation error
Message-ID: <57A2F6A3.9080908@zoho.com>
Date: Thu, 4 Aug 2016 16:02:43 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, tj@kernel.org, hannes@cmpxchg.org
Cc: mhocko@kernel.org, minchan@kernel.org, zijun_hu@htc.com, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

