Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 0C5356B0005
	for <linux-mm@kvack.org>; Wed, 20 Mar 2013 16:58:59 -0400 (EDT)
Date: Wed, 20 Mar 2013 13:58:58 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 1/4 v3]swap: change block allocation algorithm for SSD
Message-Id: <20130320135858.179ceef83b43ce434373d55b@linux-foundation.org>
In-Reply-To: <alpine.LNX.2.00.1303191329490.5966@eggly.anvils>
References: <20130221021710.GA32580@kernel.org>
	<alpine.LNX.2.00.1303191329490.5966@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>, riel@redhat.com, minchan@kernel.org, kmpark@infradead.org, linux-mm@kvack.org

On Tue, 19 Mar 2013 13:50:57 -0700 (PDT) Hugh Dickins <hughd@google.com> wrote:

> I find it a bit confusing that we now have these two different clustering
> strategies in scan_swap_map(), one for SSD and one for the rest; and it's
> not immediately obvious what's used for what.

Yes, having two separation allocation paths is bad and we should work
to avoid it, please.  Sooner rather than later (which sometimes never
comes).

We have a few theories about how the SSD code will worsen things for
rotating disks.  But have those theories been tested?  Any performance
results?  If regressions *are* observed, what is the feasibility of
fixing them up?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
