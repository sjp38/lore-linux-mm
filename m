Date: Wed, 11 Jun 2003 11:56:26 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: [2.5.70-mm8] NETDEV WATCHDOG: eth0: transmit timed out
Message-Id: <20030611115626.26ddac3a.akpm@digeo.com>
In-Reply-To: <200306111725.49952.schlicht@uni-mannheim.de>
References: <20030611013325.355a6184.akpm@digeo.com>
	<200306111356.52950.schlicht@uni-mannheim.de>
	<200306111516.46648.schlicht@uni-mannheim.de>
	<200306111725.49952.schlicht@uni-mannheim.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Thomas Schlichter <schlicht@uni-mannheim.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Thomas Schlichter <schlicht@uni-mannheim.de> wrote:
>
> OK, I've found it...!

Thanks.

> After reverting the pci-init-ordering-fix everything works as expected 
> again...

Damn.  That patch fixes other bugs.  i386 pci init ordering is busted.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
