Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id B9B2082FD8
	for <linux-mm@kvack.org>; Sun, 27 Dec 2015 05:58:19 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id l126so235701380wml.1
        for <linux-mm@kvack.org>; Sun, 27 Dec 2015 02:58:19 -0800 (PST)
Received: from vena.lwn.net (tex.lwn.net. [70.33.254.29])
        by mx.google.com with ESMTPS id et14si89694131wjc.67.2015.12.27.02.58.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 27 Dec 2015 02:58:18 -0800 (PST)
Date: Sun, 27 Dec 2015 03:58:10 -0700
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH] Documentation/kernel-parameters: update KMG units
Message-ID: <20151227035810.0c408e2d@lwn.net>
In-Reply-To: <1450917496-4023-1-git-send-email-elliott@hpe.com>
References: <1450917496-4023-1-git-send-email-elliott@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robert Elliott <elliott@hpe.com>
Cc: akpm@linux-foundation.org, mgorman@techsingularity.net, matt@codeblueprint.co.uk, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 23 Dec 2015 18:38:16 -0600
Robert Elliott <elliott@hpe.com> wrote:

> Since commit e004f3c7780d ("lib/cmdline.c: add size unit t/p/e to
> memparse") expanded memparse() to support T, P, and E units in addition
> to K, M, and G, all the kernel parameters that use that function became
> capable of more than [KMG] mentioned in kernel-parameters.txt.
> 
> Expand the introduction to the units and change all existing [KMG]
> descriptions to [KMGTPE].  cma only had [MG]; reservelow only had [K].
> 
> Add [KMGTPE] for hugepagesz and memory_corruption_check_size, which also
> use memparse().
> 
> Update two source code files with comments mentioning [KMG].

This one, too, goes outside of the docs tree, but it seems obvious enough
and I'll take the liberty of applying it.  Hopefully Andrew and company
won't get too upset if I touch page_alloc.c...

Thanks,

jon

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
