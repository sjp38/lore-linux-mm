Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 792FC900137
	for <linux-mm@kvack.org>; Sun, 31 Jul 2011 12:19:33 -0400 (EDT)
Received: by vwm42 with SMTP id 42so2220091vwm.14
        for <linux-mm@kvack.org>; Sun, 31 Jul 2011 09:19:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1107141033031.30512@router.home>
References: <alpine.DEB.2.00.1106201612310.17524@router.home>
	<1310065449.21902.60.camel@jaguar>
	<alpine.DEB.2.00.1107131710050.4557@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1107140919050.30512@router.home>
	<alpine.DEB.2.00.1107141033031.30512@router.home>
Date: Sun, 31 Jul 2011 19:19:32 +0300
Message-ID: <CAOJsxLF_BaPGx9CcYewKHs0FQdK_HfNXW5ptu2w9nAs47+GodQ@mail.gmail.com>
Subject: Re: slub: free slabs without holding locks (V2)
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org

On Thu, Jul 14, 2011 at 6:35 PM, Christoph Lameter <cl@linux.com> wrote:
> There are two situations in which slub holds a lock while releasing
> pages:
>
> =A0 =A0 =A0 =A0A. During kmem_cache_shrink()
> =A0 =A0 =A0 =A0B. During kmem_cache_close()
>
> For A build a list while holding the lock and then release the pages
> later. In case of B we are the last remaining user of the slab so
> there is no need to take the listlock.
>
> After this patch all calls to the page allocator to free pages are
> done without holding any locks.
>
> V1->V2. Remove kfree. Avoid locking in free_partial. Drop slub_lock
> too.
>
> Signed-off-by: Christoph Lameter <cl@linux.com>

I'd like to merge this patch but it doesn't apply on top of Linus'
tree. Care to resend?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
