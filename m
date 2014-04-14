Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f52.google.com (mail-la0-f52.google.com [209.85.215.52])
	by kanga.kvack.org (Postfix) with ESMTP id 60C5B6B0036
	for <linux-mm@kvack.org>; Mon, 14 Apr 2014 18:38:28 -0400 (EDT)
Received: by mail-la0-f52.google.com with SMTP id ec20so6120957lab.39
        for <linux-mm@kvack.org>; Mon, 14 Apr 2014 15:38:26 -0700 (PDT)
Received: from mail-lb0-x229.google.com (mail-lb0-x229.google.com [2a00:1450:4010:c04::229])
        by mx.google.com with ESMTPS id y6si11733582lal.68.2014.04.14.15.38.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 14 Apr 2014 15:38:25 -0700 (PDT)
Received: by mail-lb0-f169.google.com with SMTP id q8so6406925lbi.28
        for <linux-mm@kvack.org>; Mon, 14 Apr 2014 15:38:25 -0700 (PDT)
Date: Tue, 15 Apr 2014 02:38:21 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [patch 2/4] mm: Dont forget to set softdirty on file mapped fault
Message-ID: <20140414223821.GD23983@moon>
References: <20140324122838.490106581@openvz.org>
 <20140324125926.013008345@openvz.org>
 <20140414152758.a9a80782dbb94c74a27f683a@linux-foundation.org>
 <20140414223309.GC23983@moon>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140414223309.GC23983@moon>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, xemul@parallels.com

On Tue, Apr 15, 2014 at 02:33:09AM +0400, Cyrill Gorcunov wrote:
> On Mon, Apr 14, 2014 at 03:27:58PM -0700, Andrew Morton wrote:
> > 
> > This will need to be redone for current kernels, please.  New patch, new
> > title, new changelog, retest.
> 
> Sure, will resend once done.

Andrew, sorry, I'm a bit confused, jost got notifications you've picked them
up into -mm tree, right? So what I should do now -- by "current kernels" you
mean latest Linus's git repo?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
