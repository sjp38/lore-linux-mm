Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id CB4A86B003D
	for <linux-mm@kvack.org>; Fri,  6 Feb 2009 07:58:48 -0500 (EST)
Date: Fri, 6 Feb 2009 06:58:45 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: [Patch] mmu_notifiers destroyed by __mmu_notifier_release()
	retain extra mm_count.
Message-ID: <20090206125845.GC8559@sgi.com>
References: <20090205172303.GB8559@sgi.com> <alpine.DEB.1.10.0902051427280.13692@qirst.com> <20090205200214.GN8577@sgi.com> <alpine.DEB.1.10.0902051844390.17441@qirst.com> <20090206013805.GL14011@random.random> <20090206014400.GM14011@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090206014400.GM14011@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, Robin Holt <holt@sgi.com>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 06, 2009 at 02:44:00AM +0100, Andrea Arcangeli wrote:
> simply. For a moment I thought unregister wasn't mandatory because at
> some point in one of the dozen versions of the api it wasn't, but in

You are right, I am remembering an older version of the API (which I
still like better, obviously ;) ).  I also see the problems each choice
of API can cause.  I think the current API is the more reasonable
choice.  I have adjusted XPMEM to keep a copy of the mm_struct pointer
at register time with my own accompanying inc of mm_count and likewise
do the unregister and mmdrop();  This resolved my problem.

Sorry for the noise.

Andrew, could you throw this patch as away as quickly as possible.
Sorry for wasting your time.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
