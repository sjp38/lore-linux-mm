Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 15E196B006A
	for <linux-mm@kvack.org>; Fri,  8 Oct 2010 20:38:49 -0400 (EDT)
Date: Fri, 8 Oct 2010 20:38:42 -0400
From: Valerie Aurora <vaurora@redhat.com>
Subject: Re: Results of my VFS scaling evaluation.
Message-ID: <20101009003842.GH30846@shell>
References: <1286580739.3153.57.camel@bobble.smo.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1286580739.3153.57.camel@bobble.smo.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: Frank Mayhar <fmayhar@google.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, mrubin@google.com
List-ID: <linux-mm.kvack.org>

On Fri, Oct 08, 2010 at 04:32:19PM -0700, Frank Mayhar wrote:
> 
> Before going into details of the test results, however, I must say that
> the most striking thing about Nick's work how stable it is.  In all of

:D

> the work I've been doing, all the kernels I've built and run and all the
> tests I've run, I've run into no hangs and only one crash, that in an
> area that we happen to stress very heavily, for which I posted a patch,
> available at
>  http://www.kerneltrap.org/mailarchive/linux-fsdevel/2010/9/27/6886943
> The crash involved the fact that we use cgroups very heavily, and there
> was an oversight in the new d_set_d_op() routine that failed to clear
> flags before it set them.

I honestly can't stand the d_set_d_op() patch (testing flags instead
of d_op->op) because it obfuscates the code in such a way that leads
directly to this kind of bug.  I don't suppose you could test the
performance effect of that specific patch and see how big of a
difference it makes?

-VAL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
