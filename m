Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 8EDA56B005A
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 03:17:43 -0400 (EDT)
Received: by lbon3 with SMTP id n3so1168782lbo.14
        for <linux-mm@kvack.org>; Thu, 06 Sep 2012 00:17:41 -0700 (PDT)
Date: Thu, 6 Sep 2012 10:17:39 +0300 (EEST)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [PATCH 2/5] mm, slob: Add support for kmalloc_track_caller()
In-Reply-To: <CALF0-+UB6Wm0XLHk-+vQYdFsQqa9HM0n+ps5ST+ZZpL+NXRHiQ@mail.gmail.com>
Message-ID: <alpine.LFD.2.02.1209061017300.2210@tux.localdomain>
References: <1346885323-15689-1-git-send-email-elezegarcia@gmail.com> <1346885323-15689-2-git-send-email-elezegarcia@gmail.com> <alpine.DEB.2.00.1209051756270.7625@chino.kir.corp.google.com>
 <CALF0-+UB6Wm0XLHk-+vQYdFsQqa9HM0n+ps5ST+ZZpL+NXRHiQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ezequiel Garcia <elezegarcia@gmail.com>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>

On Wed, 5 Sep 2012, Ezequiel Garcia wrote:
> Mmm, you bring an interesting issue. If you look at mm/slob.c and
> include/linux/slob_def.h
> there are lots of places with -1 instead of NUMA_NO_NODE.
> 
> Do you think it's worth to prepare a patch fixing all of those?

Yes.

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
