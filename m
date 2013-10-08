Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id AD47A6B0032
	for <linux-mm@kvack.org>; Tue,  8 Oct 2013 15:50:16 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id r10so9197036pdi.0
        for <linux-mm@kvack.org>; Tue, 08 Oct 2013 12:50:16 -0700 (PDT)
Date: Tue, 8 Oct 2013 12:50:13 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 0/3] Soft dirty tracking fixes
Message-Id: <20131008125013.85dcccf418260d43b6cb120a@linux-foundation.org>
In-Reply-To: <20131008090019.527108154@gmail.com>
References: <20131008090019.527108154@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 08 Oct 2013 13:00:19 +0400 Cyrill Gorcunov <gorcunov@gmail.com> wrote:

> Hi! Here is a couple of fixes for soft dirty pages tracking.
> While first two patches are adressing issues, the last one
> is rather a cleanup which I've been asked to implement long
> ago, but I'm not sure if anyone picked it up.
> 

Do you consider the problems which patches 1 and 2 address to be
sufficiently serious to justify backporting into -stable?

I already have patch 3, as
arch-x86-mnify-pte_to_pgoff-and-pgoff_to_pte-helpers.patch (with
s/m/u).  I've queued it for transmission to the x86 guys.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
