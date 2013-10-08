Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id E16B86B0031
	for <linux-mm@kvack.org>; Tue,  8 Oct 2013 16:06:27 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id v10so9112880pde.38
        for <linux-mm@kvack.org>; Tue, 08 Oct 2013 13:06:27 -0700 (PDT)
Date: Tue, 8 Oct 2013 13:06:24 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 0/3] Soft dirty tracking fixes
Message-Id: <20131008130624.d7c50cef20d968e8c0484a41@linux-foundation.org>
In-Reply-To: <20131008200224.GB19040@moon>
References: <20131008090019.527108154@gmail.com>
	<20131008125013.85dcccf418260d43b6cb120a@linux-foundation.org>
	<20131008200224.GB19040@moon>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 9 Oct 2013 00:02:24 +0400 Cyrill Gorcunov <gorcunov@gmail.com> wrote:

> On Tue, Oct 08, 2013 at 12:50:13PM -0700, Andrew Morton wrote:
> > 
> > Do you consider the problems which patches 1 and 2 address to be
> > sufficiently serious to justify backporting into -stable?
> 
> Good question! Yeah, since dirty bit traking is in 3.11 already,
> it would be great to merge these two patches into -stable.

OK.

> Should I resend them with stable team CC'ed?

Nope, I added cc:stable to the changelogs so they should receive
consideration by Greg automatically.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
