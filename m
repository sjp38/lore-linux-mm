Date: Wed, 28 May 2008 20:35:09 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] hugetlb: fix lockdep error
Message-Id: <20080528203509.ba971514.akpm@linux-foundation.org>
In-Reply-To: <20080529032658.GH3258@wotan.suse.de>
References: <20080529015956.GC3258@wotan.suse.de>
	<20080528191657.ba5f283c.akpm@linux-foundation.org>
	<20080529022919.GD3258@wotan.suse.de>
	<20080528193808.6e053dac.akpm@linux-foundation.org>
	<20080529030745.GG3258@wotan.suse.de>
	<20080528201929.cf766924.akpm@linux-foundation.org>
	<20080529032658.GH3258@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: agl@us.ibm.com, nacc@us.ibm.com, Linux Memory Management List <linux-mm@kvack.org>, kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Thu, 29 May 2008 05:26:58 +0200 Nick Piggin <npiggin@suse.de> wrote:

> Would it help to have a big button in kconfig called "test your kernel
> patches with this", which then selects various other things?

Sigh.  Maybe.  A big stick to whack people with would be nice too.

It would be good to have some mechanism to detect the kernel version
within Kconfig.  So we could at least do things in Kconfig which make
it really really really hard to disable debug features if
CONFIG_RC_KERNEL=y.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
