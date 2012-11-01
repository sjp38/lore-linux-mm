Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 6FC416B007D
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 16:34:33 -0400 (EDT)
Date: Thu, 1 Nov 2012 20:34:32 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [glommer-memcg:slab-common/kmalloc 3/16] mm/slab_common.c:210:6:
 warning: format '%td' expects argument of type 'ptrdiff_t', but argument 3
 has type 'size_t'
In-Reply-To: <5090ee70.0VqxCVMJOPKPP7+v%fengguang.wu@intel.com>
Message-ID: <0000013abdaeaced-fa26192a-38df-4970-890d-79b8c2aaaa6e-000000@email.amazonses.com>
References: <5090ee70.0VqxCVMJOPKPP7+v%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: linux-mm@kvack.org, Glauber Costa <glommer@parallels.com>

On Wed, 31 Oct 2012, kbuild test robot wrote:

> mm/slab_common.c: In function 'create_boot_cache':
> mm/slab_common.c:210:6: warning: format '%td' expects argument of type 'ptrdiff_t', but argument 3 has type 'size_t' [-Wformat]

Ok V5 will use %zd instead of %td for the size argument.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
