Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id A631B6B006C
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 02:56:42 -0400 (EDT)
Received: by mail-ea0-f169.google.com with SMTP id k11so529727eaa.14
        for <linux-mm@kvack.org>; Tue, 30 Oct 2012 23:56:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1350600107-4558-1-git-send-email-elezegarcia@gmail.com>
References: <1350600107-4558-1-git-send-email-elezegarcia@gmail.com>
Date: Wed, 31 Oct 2012 08:56:42 +0200
Message-ID: <CAOJsxLHxgeYEmfoLrzaTNGj88xOhteBKFJKVzPqzrte-B18nSg@mail.gmail.com>
Subject: Re: [PATCH 1/3] mm/slob: Drop usage of page->private for storing
 page-sized allocations
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ezequiel Garcia <elezegarcia@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tim Bird <tim.bird@am.sony.com>

On Fri, Oct 19, 2012 at 1:41 AM, Ezequiel Garcia <elezegarcia@gmail.com> wrote:
> This field was being used to store size allocation so it could be
> retrieved by ksize(). However, it is a bad practice to not mark a page
> as a slab page and then use fields for special purposes.
> There is no need to store the allocated size and
> ksize() can simply return PAGE_SIZE << compound_order(page).
>
> Cc: Pekka Penberg <penberg@kernel.org>
> Acked-by: Christoph Lameter <cl@linux.com>
> Signed-off-by: Ezequiel Garcia <elezegarcia@gmail.com>

Applied all three patches. Thanks, Ezequiel!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
