Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f43.google.com (mail-yh0-f43.google.com [209.85.213.43])
	by kanga.kvack.org (Postfix) with ESMTP id 6907B6B0031
	for <linux-mm@kvack.org>; Wed, 15 Jan 2014 02:16:30 -0500 (EST)
Received: by mail-yh0-f43.google.com with SMTP id a41so432740yho.16
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 23:16:30 -0800 (PST)
Received: from mail-gg0-x234.google.com (mail-gg0-x234.google.com [2607:f8b0:4002:c02::234])
        by mx.google.com with ESMTPS id z48si3961352yha.131.2014.01.14.23.16.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 14 Jan 2014 23:16:29 -0800 (PST)
Received: by mail-gg0-f180.google.com with SMTP id q3so399885gge.39
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 23:16:29 -0800 (PST)
Date: Tue, 14 Jan 2014 23:16:26 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC][PATCH 1/9] mm: slab/slub: use page->list consistently
 instead of page->lru
In-Reply-To: <52D63192.3080306@sr71.net>
Message-ID: <alpine.DEB.2.02.1401142316090.19933@chino.kir.corp.google.com>
References: <20140114180042.C1C33F78@viggo.jf.intel.com> <20140114180044.1E401C47@viggo.jf.intel.com> <alpine.DEB.2.02.1401141829530.32645@chino.kir.corp.google.com> <52D63192.3080306@sr71.net>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="531381512-478612926-1389770188=:19933"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--531381512-478612926-1389770188=:19933
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT

On Tue, 14 Jan 2014, Dave Hansen wrote:

> > block/blk-mq.c: In function a??blk_mq_free_rq_mapa??:
> > block/blk-mq.c:1094:10: error: a??struct pagea?? has no member named a??lista??
> > block/blk-mq.c:1094:10: warning: initialization from incompatible pointer type [enabled by default]
> > block/blk-mq.c:1094:10: error: a??struct pagea?? has no member named a??lista??
> > block/blk-mq.c:1095:22: error: a??struct pagea?? has no member named a??lista??
> > block/blk-mq.c: In function a??blk_mq_init_rq_mapa??:
> > block/blk-mq.c:1159:22: error: a??struct pagea?? has no member named a??lista??
> 
> As I mentioned in the introduction, these are against linux-next.
> There's a patch in there at the moment which fixed this.
> 

Ok, thanks, I like this patch.

Acked-by: David Rientjes <rientjes@google.com>
--531381512-478612926-1389770188=:19933--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
