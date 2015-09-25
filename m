Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f46.google.com (mail-la0-f46.google.com [209.85.215.46])
	by kanga.kvack.org (Postfix) with ESMTP id 8E0636B0253
	for <linux-mm@kvack.org>; Fri, 25 Sep 2015 01:57:56 -0400 (EDT)
Received: by lacrr8 with SMTP id rr8so7861892lac.2
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 22:57:55 -0700 (PDT)
Received: from mail-la0-x22c.google.com (mail-la0-x22c.google.com. [2a00:1450:4010:c03::22c])
        by mx.google.com with ESMTPS id r199si935843lfe.160.2015.09.24.22.57.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Sep 2015 22:57:54 -0700 (PDT)
Received: by lacao8 with SMTP id ao8so86807933lac.3
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 22:57:54 -0700 (PDT)
Date: Fri, 25 Sep 2015 07:57:53 +0200
From: Vitaly Wool <vitalywool@gmail.com>
Subject: [PATCH v3] zbud: allow up to PAGE_SIZE allocations
Message-Id: <20150925075753.90ff10d13070717e3a6b10ca@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjennings@variantweb.net>, Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

