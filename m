Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9056D8E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 05:19:40 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id t17so4807838ywc.23
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 02:19:40 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id d203si313114ybd.387.2019.01.17.02.19.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Jan 2019 02:19:39 -0800 (PST)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH] mm/page_alloc: check return value of
 memblock_alloc_node_nopanic()
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <1547621481-8374-1-git-send-email-rppt@linux.ibm.com>
Date: Thu, 17 Jan 2019 03:19:35 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <5195030D-7ED9-4074-AB6C-92A3AFF11E00@oracle.com>
References: <1547621481-8374-1-git-send-email-rppt@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


This seems very reasonable, but if the code is just going to panic if =
the allocation fails, why not call memblock_alloc_node() instead?

If there is a reason we'd prefer to call memblock_alloc_node_nopanic(), =
I'd like to see pgdat->nodeid printed in the panic message as well.
