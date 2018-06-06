Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4ECD16B0003
	for <linux-mm@kvack.org>; Wed,  6 Jun 2018 19:48:16 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id j11-v6so7641506qtf.15
        for <linux-mm@kvack.org>; Wed, 06 Jun 2018 16:48:16 -0700 (PDT)
Received: from a9-54.smtp-out.amazonses.com (a9-54.smtp-out.amazonses.com. [54.240.9.54])
        by mx.google.com with ESMTPS id a9-v6si6942477qvh.29.2018.06.06.16.48.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 06 Jun 2018 16:48:15 -0700 (PDT)
Date: Wed, 6 Jun 2018 23:48:14 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH] slab: Clean up the code comment in slab kmem_cache
 struct
In-Reply-To: <20180606012624.GA19425@MiWiFi-R3L-srv>
Message-ID: <01000163d7803909-286c20d2-9928-4e07-94fc-ee6552e04c67-000000@email.amazonses.com>
References: <20180603032402.27526-1-bhe@redhat.com> <01000163d0e8083c-096b06d6-7202-4ce2-b41c-0f33784afcda-000000@email.amazonses.com> <20180606012624.GA19425@MiWiFi-R3L-srv>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baoquan He <bhe@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org

On Wed, 6 Jun 2018, Baoquan He wrote:

> I am back porting Thomas's sl[a|u]b freelist randomization feature to
> our distros, need go through slab code for better understanding. From
> git log history, they were 'obj_offset' and 'obj_size'. Later on
> 'obj_size' was renamed to 'object_size' in commit 3b0efdfa1e("mm, sl[aou]b:
> Extract common fields from struct kmem_cache") which is from your patch.
> With my understanding, I guess you changed that on purpose because
> object_size is size of each object, obj_offset is for the whole cache,
> representing the offset the real object starts to be stored. And putting
> them separately is for better desribing them in code comment and
> distinction, e.g 'object_size' is in "4) cache creation/removal",
> while 'obj_offset' is put alone to indicate it's for the whole.

obj_offset only applies when CONFIG_SLAB_DEBUG is set. Ok so that screwy
name also indicates that something special goes on.
