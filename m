Date: Tue, 9 Nov 2004 11:46:46 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] zap_pte_range should not mark non-uptodate pages dirty
Message-Id: <20041109114646.1781757a.akpm@osdl.org>
In-Reply-To: <1100009730.7478.1.camel@localhost>
References: <1098393346.7157.112.camel@localhost>
	<20041021144531.22dd0d54.akpm@osdl.org>
	<20041021223613.GA8756@dualathlon.random>
	<20041021160233.68a84971.akpm@osdl.org>
	<20041021232059.GE8756@dualathlon.random>
	<20041021164245.4abec5d2.akpm@osdl.org>
	<20041022003004.GA14325@dualathlon.random>
	<20041022012211.GD14325@dualathlon.random>
	<20041021190320.02dccda7.akpm@osdl.org>
	<20041022161744.GF14325@dualathlon.random>
	<20041022162433.509341e4.akpm@osdl.org>
	<1100009730.7478.1.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Kleikamp <shaggy@austin.ibm.com>
Cc: andrea@novell.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Dave Kleikamp <shaggy@austin.ibm.com> wrote:
>
> Andrew & Andrea,
> What is the status of this patch?  It would be nice to have it in the
> -mm4 kernel.
> 

I found that the patch was causing I/O errors to be reported with one of
the LTP tests:

testcases/bin/growfiles -W gf15 -b -e 1 -u -r 1-49600 -I r -u -i 0 -L 120 Lgfile1

So I dropped it out pending a bit more work.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
