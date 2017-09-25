Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id AE3646B0069
	for <linux-mm@kvack.org>; Mon, 25 Sep 2017 15:28:05 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id h16so10095449wrf.0
        for <linux-mm@kvack.org>; Mon, 25 Sep 2017 12:28:05 -0700 (PDT)
Received: from fireflyinternet.com (mail.fireflyinternet.com. [109.228.58.192])
        by mx.google.com with ESMTPS id 14si126018wmv.13.2017.09.25.12.28.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Sep 2017 12:28:04 -0700 (PDT)
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
From: Chris Wilson <chris@chris-wilson.co.uk>
In-Reply-To: <20170925184737.8807-4-matthew.auld@intel.com>
References: <20170925184737.8807-1-matthew.auld@intel.com>
 <20170925184737.8807-4-matthew.auld@intel.com>
Message-ID: <150636768123.32171.13752171915783422673@mail.alporthouse.com>
Subject: Re: [PATCH 03/22] mm/shmem: parse mount options for MS_KERNMOUNT
Date: Mon, 25 Sep 2017 20:28:01 +0100
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Auld <matthew.auld@intel.com>, intel-gfx@lists.freedesktop.org
Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, "Kirill A . Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

Quoting Matthew Auld (2017-09-25 19:47:18)
> In i915 we now have our own tmpfs mount, so ensure that shmem_fill_super
> also calls shmem_parse_options when dealing with a kernel mount.
> Otherwise we have to clumsily call remount_fs when we want to supply our
> mount options.
> =

> Signed-off-by: Matthew Auld <matthew.auld@intel.com>
> Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
> Cc: Chris Wilson <chris@chris-wilson.co.uk>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Cc: Kirill A. Shutemov <kirill@shutemov.name>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: linux-mm@kvack.org

I could not find a counter argument why all kernel users had to skip
shmem_parse_options(), is there a danger that data may be anything other
than a string or NULL?
-Chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
