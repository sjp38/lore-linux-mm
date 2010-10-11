Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7FF156B0071
	for <linux-mm@kvack.org>; Mon, 11 Oct 2010 14:47:37 -0400 (EDT)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id o9BIlZ2C015887
	for <linux-mm@kvack.org>; Mon, 11 Oct 2010 11:47:36 -0700
Received: from vws1 (vws1.prod.google.com [10.241.21.129])
	by wpaz1.hot.corp.google.com with ESMTP id o9BIlYZ9004099
	for <linux-mm@kvack.org>; Mon, 11 Oct 2010 11:47:34 -0700
Received: by vws1 with SMTP id 1so1895299vws.27
        for <linux-mm@kvack.org>; Mon, 11 Oct 2010 11:47:34 -0700 (PDT)
Subject: Re: Results of my VFS scaling evaluation.
From: Frank Mayhar <fmayhar@google.com>
In-Reply-To: <20101009003842.GH30846@shell>
References: <1286580739.3153.57.camel@bobble.smo.corp.google.com>
	 <20101009003842.GH30846@shell>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 11 Oct 2010 11:47:28 -0700
Message-ID: <1286822848.29899.305.camel@bobble.smo.corp.google.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Valerie Aurora <vaurora@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, mrubin@google.com
List-ID: <linux-mm.kvack.org>

On Fri, 2010-10-08 at 20:38 -0400, Valerie Aurora wrote:
> On Fri, Oct 08, 2010 at 04:32:19PM -0700, Frank Mayhar wrote:
> > 
> > Before going into details of the test results, however, I must say that
> > the most striking thing about Nick's work how stable it is.  In all of
> 
> :D
> 
> > the work I've been doing, all the kernels I've built and run and all the
> > tests I've run, I've run into no hangs and only one crash, that in an
> > area that we happen to stress very heavily, for which I posted a patch,
> > available at
> >  http://www.kerneltrap.org/mailarchive/linux-fsdevel/2010/9/27/6886943
> > The crash involved the fact that we use cgroups very heavily, and there
> > was an oversight in the new d_set_d_op() routine that failed to clear
> > flags before it set them.
> 
> I honestly can't stand the d_set_d_op() patch (testing flags instead
> of d_op->op) because it obfuscates the code in such a way that leads
> directly to this kind of bug.  I don't suppose you could test the
> performance effect of that specific patch and see how big of a
> difference it makes?

I do kind of understand why he did it but you're right that it makes
things a bit error-prone.  Unfortunately I'm not in a position at the
moment to do a lot more testing and analysis.  I'll try to find some
spare time in which to do some more testing of both this and Dave
Chinner's tree, but no promises.
-- 
Frank Mayhar <fmayhar@google.com>
Google Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
