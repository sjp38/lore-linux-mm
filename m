Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id C60246B0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2013 21:25:21 -0500 (EST)
Received: by mail-vb0-f46.google.com with SMTP id b13so5479071vby.33
        for <linux-mm@kvack.org>; Wed, 20 Feb 2013 18:25:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CANZA+xgRWQe2fm8Gok4SxRXEeRU5CztijG4HKNeTDFQfSgHPPw@mail.gmail.com>
References: <CANZA+xgRWQe2fm8Gok4SxRXEeRU5CztijG4HKNeTDFQfSgHPPw@mail.gmail.com>
Date: Thu, 21 Feb 2013 10:25:20 +0800
Message-ID: <CANZA+xgjxezRuu4N2JpXbXjpKCz7825x_ZmdOe-DuxtMzGix-A@mail.gmail.com>
Subject: Re: What does the PG_swapbacked of page flags actually mean?
From: common An <xx.kernel@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org, riel@redhat.com

On Wed, Feb 20, 2013 at 6:43 PM, common An <xx.kernel@gmail.com> wrote:
> PG_swapbacked is a bit for page->flags.
>
> In kernel code, its comment is "page is backed by RAM/swap". But I couldn't
> understand it.
> 1. Does the RAM mean DRAM? How page is backed by RAM?
> 2. When the page is page-out to swap file, the bit PG_swapbacked will be set
> to demonstrate this page is backed by swap. Is it right?
> 3. In general, when will call SetPageSwapBacked() to set the bit?

>From : http://www.gossamer-threads.com/lists/linux/kernel/840692#840692

Every anonymous, tmpfs or shared memory segment page is potentially
swap backed. That is the whole point of the PG_swapbacked flag.

A page from a filesystem like ext3 or NFS cannot suddenly turn into
a swap backed page. This page "nature" is not changed during the
lifetime of a page.

But, I am still a little confusing.

>
> Could anybody kindly explain for me?
>
> Thanks very much.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
