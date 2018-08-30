Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 940D46B524A
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 11:33:50 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id y54-v6so8399993qta.8
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 08:33:50 -0700 (PDT)
Received: from a9-99.smtp-out.amazonses.com (a9-99.smtp-out.amazonses.com. [54.240.9.99])
        by mx.google.com with ESMTPS id b191-v6si2857582qka.238.2018.08.30.08.33.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 30 Aug 2018 08:33:49 -0700 (PDT)
Date: Thu, 30 Aug 2018 15:33:48 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH v1] mm/slub.c: Switch to bitmap_zalloc()
In-Reply-To: <20180830104301.61649-1-andriy.shevchenko@linux.intel.com>
Message-ID: <010001658b781a67-c9e35a61-d237-480e-8912-ebc21228fc77-000000@email.amazonses.com>
References: <20180830104301.61649-1-andriy.shevchenko@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>


Acked-by: Christoph Lameter <cl@linux.com>
