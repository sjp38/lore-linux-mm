Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6121B6B0038
	for <linux-mm@kvack.org>; Mon,  1 May 2017 10:39:36 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id d11so44791940pgn.9
        for <linux-mm@kvack.org>; Mon, 01 May 2017 07:39:36 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id x17si2945524pgx.215.2017.05.01.07.39.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 May 2017 07:39:35 -0700 (PDT)
Date: Mon, 1 May 2017 07:39:30 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 2/3] mm/slub: wrap cpu_slab->partial in
 CONFIG_SLUB_CPU_PARTIAL
Message-ID: <20170501143930.GJ27790@bombadil.infradead.org>
References: <20170430113152.6590-1-richard.weiyang@gmail.com>
 <20170430113152.6590-3-richard.weiyang@gmail.com>
 <20170501024103.GI27790@bombadil.infradead.org>
 <20170501082005.GA2006@WeideMacBook-Pro.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170501082005.GA2006@WeideMacBook-Pro.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, May 01, 2017 at 04:20:05PM +0800, Wei Yang wrote:
> I have tried to replace the code with slub_cpu_partial(), it works fine on
> most of cases except two:
> 
> 1. slub_cpu_partial(c) = page->next;

New accessor: slub_set_cpu_partial(c, p)

> 2. page = READ_ONCE(slub_cpu_partial(c));

OK, that one I haven't seen an existing pattern for yet.
slub_cpu_partial_read_once(c)?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
