Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C8A2C6B0292
	for <linux-mm@kvack.org>; Mon, 22 May 2017 17:45:04 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id n75so142132560pfh.0
        for <linux-mm@kvack.org>; Mon, 22 May 2017 14:45:04 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 59si18547162pld.76.2017.05.22.14.45.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 May 2017 14:45:03 -0700 (PDT)
Date: Mon, 22 May 2017 14:45:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/3] mm/slub: Only define kmalloc_large_node_hook() for
 NUMA systems
Message-Id: <20170522144501.2d02b5799e07167dc5aecf3e@linux-foundation.org>
In-Reply-To: <20170522205621.GL141096@google.com>
References: <20170519210036.146880-1-mka@chromium.org>
	<20170519210036.146880-2-mka@chromium.org>
	<alpine.DEB.2.10.1705221338100.30407@chino.kir.corp.google.com>
	<20170522205621.GL141096@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthias Kaehlcke <mka@chromium.org>
Cc: David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 22 May 2017 13:56:21 -0700 Matthias Kaehlcke <mka@chromium.org> wrote:

> El Mon, May 22, 2017 at 01:39:26PM -0700 David Rientjes ha dit:
> 
> > On Fri, 19 May 2017, Matthias Kaehlcke wrote:
> > 
> > > The function is only used when CONFIG_NUMA=y. Placing it in an #ifdef
> > > block fixes the following warning when building with clang:
> > > 
> > > mm/slub.c:1246:20: error: unused function 'kmalloc_large_node_hook'
> > >     [-Werror,-Wunused-function]
> > > 
> > 
> > Is clang not inlining kmalloc_large_node_hook() for some reason?  I don't 
> > think this should ever warn on gcc.
> 
> clang warns about unused static inline functions outside of header
> files, in difference to gcc.

I wish it wouldn't.  These patches just add clutter.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
