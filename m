Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id AF4236B0047
	for <linux-mm@kvack.org>; Sun, 17 Jan 2010 10:43:52 -0500 (EST)
Date: Sun, 17 Jan 2010 10:43:43 -0500
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v3 06/12] Add get_user_pages() variant that fails if
	major fault is required.
Message-ID: <20100117154343.GA27123@infradead.org>
References: <1262700774-1808-1-git-send-email-gleb@redhat.com> <1262700774-1808-7-git-send-email-gleb@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1262700774-1808-7-git-send-email-gleb@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 05, 2010 at 04:12:48PM +0200, Gleb Natapov wrote:
> This patch add get_user_pages() variant that only succeeds if getting
> a reference to a page doesn't require major fault.

>  
> +int get_user_pages_noio(struct task_struct *tsk, struct mm_struct *mm,
> +		unsigned long start, int nr_pages, int write, int force,
> +		struct page **pages, struct vm_area_struct **vmas)
> +{
> +	int flags = FOLL_TOUCH | FOLL_MINOR;
> +
> +	if (pages)
> +		flags |= FOLL_GET;
> +	if (write)
> +		flags |= FOLL_WRITE;
> +	if (force)
> +		flags |= FOLL_FORCE;
> +
> +	return __get_user_pages(tsk, mm, start, nr_pages, flags, pages, vmas);

Wouldn't it be better to just export __get_user_pages as a proper user
interface, maybe replacing get_user_pages by it entirely?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
