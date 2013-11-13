Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 972286B00A1
	for <linux-mm@kvack.org>; Wed, 13 Nov 2013 08:19:28 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id z10so400264pdj.2
        for <linux-mm@kvack.org>; Wed, 13 Nov 2013 05:19:28 -0800 (PST)
Received: from psmtp.com ([74.125.245.118])
        by mx.google.com with SMTP id rz8si2783161pab.271.2013.11.13.05.19.25
        for <linux-mm@kvack.org>;
        Wed, 13 Nov 2013 05:19:26 -0800 (PST)
Received: by mail-la0-f45.google.com with SMTP id eh20so331707lab.18
        for <linux-mm@kvack.org>; Wed, 13 Nov 2013 05:19:23 -0800 (PST)
Date: Wed, 13 Nov 2013 17:19:21 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: Unnecessary mass OOM kills on Linux 3.11 virtualization host
Message-ID: <20131113131921.GF2834@moon>
References: <20131024224326.GA19654@alpha.arachsys.com>
 <20131025103946.GA30649@alpha.arachsys.com>
 <20131028082825.GA30504@alpha.arachsys.com>
 <52836002.5050901@elastichosts.com>
 <20131113120948.GE2834@moon>
 <52837216.1090100@elastichosts.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52837216.1090100@elastichosts.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alin Dobre <alin.dobre@elastichosts.com>
Cc: linux-mm@kvack.org

On Wed, Nov 13, 2013 at 12:35:34PM +0000, Alin Dobre wrote:
> On 13/11/13 12:09, Cyrill Gorcunov wrote:
> >On Wed, Nov 13, 2013 at 11:18:26AM +0000, Alin Dobre wrote:
> >>
> >>The above traces seem similar with the ones that were reported by
> >>Dave couple of months ago in the LKML thread
> >>https://lkml.org/lkml/2013/8/7/27.
> >>
> >>Any further thoughts on why this happens?
> >
> >Dave's report has been addressed in commit 6dec97dc9, which is
> >in 3.11, also you're to have CONFIG_MEM_SOFT_DIRTY=y to trigger
> >it in former case.
> 
> Thanks a lot, Cyrill. That's a really good piece of information, we
> must have missed it although it was clearly there.
> 
> In the meantime, we will try to reproduce the problem and see if
> this fix together with CONFIG_MEM_SOFT_DIRTY=y works for our OOM
> kills also.

Hi Alin, actually if your config has no CONFIG_MEM_SOFT_DIRTY=y
then the fix won't help, it might be some different issue (Dave
has been testing the kernel with soft-dirty option set). But of
course I don't mind if you test the kernel with soft dirty option
turned on.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
