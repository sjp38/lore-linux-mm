Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 38DD58E0001
	for <linux-mm@kvack.org>; Mon, 24 Sep 2018 11:12:54 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id d205-v6so2236391qkg.16
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 08:12:54 -0700 (PDT)
Received: from a9-99.smtp-out.amazonses.com (a9-99.smtp-out.amazonses.com. [54.240.9.99])
        by mx.google.com with ESMTPS id m27-v6si794994qtm.216.2018.09.24.08.12.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 24 Sep 2018 08:12:53 -0700 (PDT)
Date: Mon, 24 Sep 2018 15:12:53 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH v9 10/20] mm: move obj_to_index to
 include/linux/slab_def.h
In-Reply-To: <9d62f917393456653c1d38c7173dc876cef03c93.1537542735.git.andreyknvl@google.com>
Message-ID: <010001660c23edab-ad0e9fb7-2b96-45ef-b875-6f025132ed3f-000000@email.amazonses.com>
References: <cover.1537542735.git.andreyknvl@google.com> <9d62f917393456653c1d38c7173dc876cef03c93.1537542735.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org


Acked-by: Christoph Lameter <cl@linux.com>
