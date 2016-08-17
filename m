Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6F35C6B0038
	for <linux-mm@kvack.org>; Wed, 17 Aug 2016 15:03:59 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id h186so242873898pfg.2
        for <linux-mm@kvack.org>; Wed, 17 Aug 2016 12:03:59 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id bf8si479750pad.59.2016.08.17.12.03.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Aug 2016 12:03:58 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id i6so8629965pfe.0
        for <linux-mm@kvack.org>; Wed, 17 Aug 2016 12:03:58 -0700 (PDT)
Message-ID: <1471460636.29842.20.camel@edumazet-glaptop3.roam.corp.google.com>
Subject: Re: [PATCH v3] mm/slab: Improve performance of gathering slabinfo
 stats
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 17 Aug 2016 12:03:56 -0700
In-Reply-To: <1471458050-29622-1-git-send-email-aruna.ramakrishna@oracle.com>
References: <1471458050-29622-1-git-send-email-aruna.ramakrishna@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aruna Ramakrishna <aruna.ramakrishna@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Kravetz <mike.kravetz@oracle.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed, 2016-08-17 at 11:20 -0700, Aruna Ramakrishna wrote:
]
> -		list_for_each_entry(page, &n->slabs_full, lru) {
> -			if (page->active != cachep->num && !error)
> -				error = "slabs_full accounting error";
> -			active_objs += cachep->num;
> -			active_slabs++;
> -		}

Since you only removed this loop, you could track only number of
full_slabs.

This would avoid messing with n->num_slabs all over the places in fast
path.

Please also update slab_out_of_memory()





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
