Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 4D4B46B005D
	for <linux-mm@kvack.org>; Mon, 20 Aug 2012 15:11:45 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so6493473ghr.14
        for <linux-mm@kvack.org>; Mon, 20 Aug 2012 12:11:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CANN689Hch8ao9MnV0Luk6_b0kFJtcvfZZ7jEGWyvUN41Q=FWnA@mail.gmail.com>
References: <20120816024610.GA5350@evergreen.ssec.wisc.edu>
	<502D42E5.7090403@redhat.com>
	<20120818000312.GA4262@evergreen.ssec.wisc.edu>
	<502F100A.1080401@redhat.com>
	<alpine.LSU.2.00.1208200032450.24855@eggly.anvils>
	<CANN689Ej7XLh8VKuaPrTttDrtDGQbXuYJgS2uKnZL2EYVTM3Dg@mail.gmail.com>
	<50321CD3.5050501@redhat.com>
	<CANN689Hch8ao9MnV0Luk6_b0kFJtcvfZZ7jEGWyvUN41Q=FWnA@mail.gmail.com>
Date: Mon, 20 Aug 2012 12:11:43 -0700
Message-ID: <CANN689FiU87Vju7zTJ2yZNkw2aDd=K05fRKhoRGTn6Dp8btjLg@mail.gmail.com>
Subject: Re: Repeated fork() causes SLAB to grow without bound
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Daniel Forrest <dan.forrest@ssec.wisc.edu>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Aug 20, 2012 at 4:53 AM, Michel Lespinasse <walken@google.com> wrote:
> I wonder if it might help to add the child VMA onto the parent's
> anon_vma only at the first child COW event. That way it would at least
> be possible (with userspace changes) for any forking servers to
> separate the areas they want to write into from the parent (such as
> things that need expensive initialization), from the ones that they
> want to write into from the child, and have none of the anon_vma lists
> grow too large.

Actually that wouldn't work. The parent's anon pages are visible from
the child, so the child vma needs to be on the parent anon_vma list.
Sorry for the noise :/

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
