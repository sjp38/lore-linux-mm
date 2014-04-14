Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 44A3D6B0037
	for <linux-mm@kvack.org>; Mon, 14 Apr 2014 18:43:54 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id v10so8670347pde.11
        for <linux-mm@kvack.org>; Mon, 14 Apr 2014 15:43:53 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id l7si4500742pbd.21.2014.04.14.15.43.53
        for <linux-mm@kvack.org>;
        Mon, 14 Apr 2014 15:43:53 -0700 (PDT)
Date: Mon, 14 Apr 2014 15:43:51 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 2/4] mm: Dont forget to set softdirty on file mapped
 fault
Message-Id: <20140414154351.9f09c43002463407a2b5f8b7@linux-foundation.org>
In-Reply-To: <20140414223821.GD23983@moon>
References: <20140324122838.490106581@openvz.org>
	<20140324125926.013008345@openvz.org>
	<20140414152758.a9a80782dbb94c74a27f683a@linux-foundation.org>
	<20140414223309.GC23983@moon>
	<20140414223821.GD23983@moon>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, xemul@parallels.com

On Tue, 15 Apr 2014 02:38:21 +0400 Cyrill Gorcunov <gorcunov@gmail.com> wrote:

> On Tue, Apr 15, 2014 at 02:33:09AM +0400, Cyrill Gorcunov wrote:
> > On Mon, Apr 14, 2014 at 03:27:58PM -0700, Andrew Morton wrote:
> > > 
> > > This will need to be redone for current kernels, please.  New patch, new
> > > title, new changelog, retest.
> > 
> > Sure, will resend once done.
> 
> Andrew, sorry, I'm a bit confused, jost got notifications you've picked them
> up into -mm tree, right?

1, 3 and 4.

> So what I should do now -- by "current kernels" you
> mean latest Linus's git repo?

yup.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
