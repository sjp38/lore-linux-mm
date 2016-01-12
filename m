Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 9C5CF680F84
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 20:31:27 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id f206so296581944wmf.0
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 17:31:27 -0800 (PST)
Received: from vena.lwn.net (tex.lwn.net. [70.33.254.29])
        by mx.google.com with ESMTPS id c10si203226786wjb.83.2016.01.11.17.31.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Jan 2016 17:31:26 -0800 (PST)
Date: Mon, 11 Jan 2016 18:31:22 -0700
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH] Documentation/kernel-parameters: update KMG units
Message-ID: <20160111183122.1f7e5728@lwn.net>
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

So I've ended up dropping this one from the docs tree for now.  In the
end, I just didn't want my pull request to include an explanation for why
the docs tree has a conflict on mm/page_alloc.c....  The change is good,
though, and shouldn't be lost.  I'd say that either (1) Andrew can pick
it up and merge it with the other stuff he has, or (2) we can push it
through after mm has cleared.  Either way, a version based on -mm would
be a good thing to have.

Thanks,

jon

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
