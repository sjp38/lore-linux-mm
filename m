Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 005766B0071
	for <linux-mm@kvack.org>; Wed, 16 Jan 2013 10:05:10 -0500 (EST)
Date: Wed, 16 Jan 2013 15:05:07 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/3] slub: correct bootstrap() for kmem_cache,
 kmem_cache_node
In-Reply-To: <20130116084459.GB13446@lge.com>
Message-ID: <0000013c43e46737-a6429216-478b-4cac-b618-447bf003a063-000000@email.amazonses.com>
References: <1358234402-2615-1-git-send-email-iamjoonsoo.kim@lge.com> <1358234402-2615-2-git-send-email-iamjoonsoo.kim@lge.com> <0000013c3eda78d8-da8c775c-d7c0-4a88-bacf-0b5160b5c668-000000@email.amazonses.com> <20130116084459.GB13446@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 16 Jan 2013, Joonsoo Kim wrote:

> These slabs are not on the partial list, but on the cpu_slab of boot cpu.

> Reason for this is described in changelog.
> Because these slabs are not on partial list, we need to
> check kmem_cache_cpu's cpu slab. This patch implement it.

Ah. Ok.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
