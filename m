Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 3ECE46B0068
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 03:28:54 -0400 (EDT)
Received: by wgbdq12 with SMTP id dq12so4148910wgb.26
        for <linux-mm@kvack.org>; Tue, 04 Sep 2012 00:28:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1344974585-9701-1-git-send-email-elezegarcia@gmail.com>
References: <1344974585-9701-1-git-send-email-elezegarcia@gmail.com>
Date: Tue, 4 Sep 2012 10:28:52 +0300
Message-ID: <CAOJsxLFqn7mtARqJ4PY0HyMa+uo28VXb52gNo4JNzthDVmJSSw@mail.gmail.com>
Subject: Re: [PATCH] mm, slob: Drop usage of page->private for storing
 page-sized allocations
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ezequiel Garcia <elezegarcia@gmail.com>
Cc: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Glauber Costa <glommer@parallels.com>

Hi Ezequiel,

On Tue, Aug 14, 2012 at 11:03 PM, Ezequiel Garcia <elezegarcia@gmail.com> wrote:
> This field was being used to store size allocation so it could be
> retrieved by ksize(). However, it is a bad practice to not mark a page
> as a slab page and then use fields for special purposes.
> There is no need to store the allocated size and
> ksize() can simply return PAGE_SIZE << compound_order(page).
>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Glauber Costa <glommer@parallels.com>
> Signed-off-by: Ezequiel Garcia <elezegarcia@gmail.com>

I'm getting rejects for this. Care to resend against latest slab/next branch?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
