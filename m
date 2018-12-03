Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 682236B69EA
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 11:13:55 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id d18so8149814pfe.0
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 08:13:55 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id y2si14713876pli.266.2018.12.03.08.13.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Dec 2018 08:13:54 -0800 (PST)
Date: Mon, 3 Dec 2018 08:13:53 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: Number of arguments in vmalloc.c
Message-ID: <20181203161352.GP10377@bombadil.infradead.org>
References: <20181128140136.GG10377@bombadil.infradead.org>
 <3264149f-e01e-faa2-3bc8-8aa1c255e075@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3264149f-e01e-faa2-3bc8-8aa1c255e075@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org

On Mon, Dec 03, 2018 at 02:59:36PM +0100, Vlastimil Babka wrote:
> On 11/28/18 3:01 PM, Matthew Wilcox wrote:
> > 
> > Some of the functions in vmalloc.c have as many as nine arguments.
> > So I thought I'd have a quick go at bundling the ones that make sense
> > into a struct and pass around a pointer to that struct.  Well, it made
> > the generated code worse,
> 
> Worse in which metric?

More instructions to accomplish the same thing.

> > so I thought I'd share my attempt so nobody
> > else bothers (or soebody points out that I did something stupid).
> 
> I guess in some of the functions the args parameter could be const?
> Might make some difference.
> 
> Anyway this shouldn't be a fast path, so even if the generated code is
> e.g. somewhat larger, then it still might make sense to reduce the
> insane parameter lists.

It might ... I'm not sure it's even easier to program than the original
though.
