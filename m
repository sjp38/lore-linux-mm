Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 169296B0031
	for <linux-mm@kvack.org>; Wed, 15 Jan 2014 01:58:30 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id x10so731890pdj.2
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 22:58:29 -0800 (PST)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id ot3si2761408pac.282.2014.01.14.22.58.26
        for <linux-mm@kvack.org>;
        Tue, 14 Jan 2014 22:58:26 -0800 (PST)
Message-ID: <52D63192.3080306@sr71.net>
Date: Tue, 14 Jan 2014 22:58:26 -0800
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 1/9] mm: slab/slub: use page->list consistently instead
 of page->lru
References: <20140114180042.C1C33F78@viggo.jf.intel.com> <20140114180044.1E401C47@viggo.jf.intel.com> <alpine.DEB.2.02.1401141829530.32645@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1401141829530.32645@chino.kir.corp.google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>

On 01/14/2014 06:31 PM, David Rientjes wrote:
> Did you try with a CONFIG_BLOCK config?
> 
> block/blk-mq.c: In function a??blk_mq_free_rq_mapa??:
> block/blk-mq.c:1094:10: error: a??struct pagea?? has no member named a??lista??
> block/blk-mq.c:1094:10: warning: initialization from incompatible pointer type [enabled by default]
> block/blk-mq.c:1094:10: error: a??struct pagea?? has no member named a??lista??
> block/blk-mq.c:1095:22: error: a??struct pagea?? has no member named a??lista??
> block/blk-mq.c: In function a??blk_mq_init_rq_mapa??:
> block/blk-mq.c:1159:22: error: a??struct pagea?? has no member named a??lista??

As I mentioned in the introduction, these are against linux-next.
There's a patch in there at the moment which fixed this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
