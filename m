Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 86D176B006A
	for <linux-mm@kvack.org>; Fri,  8 Oct 2010 20:34:06 -0400 (EDT)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id o990Y2Vt028122
	for <linux-mm@kvack.org>; Fri, 8 Oct 2010 17:34:02 -0700
Received: from gwaa11 (gwaa11.prod.google.com [10.200.27.11])
	by wpaz21.hot.corp.google.com with ESMTP id o990XdUN016696
	for <linux-mm@kvack.org>; Fri, 8 Oct 2010 17:34:01 -0700
Received: by gwaa11 with SMTP id a11so1130255gwa.40
        for <linux-mm@kvack.org>; Fri, 08 Oct 2010 17:33:59 -0700 (PDT)
Subject: Re: Results of my VFS scaling evaluation.
From: Frank Mayhar <fmayhar@google.com>
In-Reply-To: <1286580739.3153.57.camel@bobble.smo.corp.google.com>
References: <1286580739.3153.57.camel@bobble.smo.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 08 Oct 2010 17:33:55 -0700
Message-ID: <1286584435.3153.59.camel@bobble.smo.corp.google.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org
Cc: linux-mm@kvack.org, mrubin@google.com
List-ID: <linux-mm.kvack.org>

On Fri, 2010-10-08 at 16:32 -0700, Frank Mayhar wrote:
> Finally, I have kernel profiles for all of the above tests, all of which
> are excessively huge, too huge to even look at in their entirety.  To
> glean the above numbers I used "perf report" in its call-graph mode,
> focusing on locking primitives and percentages above around 0.5%.  I
> kept a copy of the profiles I looked at and they are available upon
> request (just ask).  I will also post them publicly as soon as I have a
> place to put them.

While there will be a more official place eventually, for the moment the
profiles can be found here:
    http://code.google.com/p/vfs-scaling-eval/downloads/list
-- 
Frank Mayhar <fmayhar@google.com>
Google Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
