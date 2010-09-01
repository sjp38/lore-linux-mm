Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 233B86B004D
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 15:51:01 -0400 (EDT)
Date: Wed, 1 Sep 2010 21:50:52 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [patch] transparent hugepage sysfs meminfo
Message-ID: <20100901195052.GC20316@random.random>
References: <20100901190859.GA20316@random.random>
 <alpine.DEB.2.00.1009011244130.4951@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1009011244130.4951@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 01, 2010 at 12:44:35PM -0700, David Rientjes wrote:
> Add hugepage statistics to per-node sysfs meminfo

Applied now.

Thanks for the resend, last version I got it when I was on vacation,
and it slipped sorry.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
