Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 03E066B6967
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 08:59:40 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id o21so6556330edq.4
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 05:59:39 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i55si3293163eda.23.2018.12.03.05.59.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 05:59:38 -0800 (PST)
Subject: Re: Number of arguments in vmalloc.c
References: <20181128140136.GG10377@bombadil.infradead.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <3264149f-e01e-faa2-3bc8-8aa1c255e075@suse.cz>
Date: Mon, 3 Dec 2018 14:59:36 +0100
MIME-Version: 1.0
In-Reply-To: <20181128140136.GG10377@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org

On 11/28/18 3:01 PM, Matthew Wilcox wrote:
> 
> Some of the functions in vmalloc.c have as many as nine arguments.
> So I thought I'd have a quick go at bundling the ones that make sense
> into a struct and pass around a pointer to that struct.  Well, it made
> the generated code worse,

Worse in which metric?

> so I thought I'd share my attempt so nobody
> else bothers (or soebody points out that I did something stupid).

I guess in some of the functions the args parameter could be const?
Might make some difference.

Anyway this shouldn't be a fast path, so even if the generated code is
e.g. somewhat larger, then it still might make sense to reduce the
insane parameter lists.

> I tried a few variations on this theme; bundling gfp_t and node into
> the struct made it even worse, as did adding caller and vm_flags.  This
> is the least bad version.
> 
> (Yes, the naming is bad; I'm not tidying this up for submission, I'm
> showing an experiment that didn't work).
> 
> Nacked-by: Matthew Wilcox <willy@infradead.org>
> 
