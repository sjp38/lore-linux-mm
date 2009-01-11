Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id EE22D6B004F
	for <linux-mm@kvack.org>; Sat, 10 Jan 2009 19:09:15 -0500 (EST)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [BUG] 2.6.28-git-4 - powerpc - kernel expection 'c01 at .kernel_thread'
Date: Sun, 11 Jan 2009 01:08:19 +0100
References: <20090102125752.GA5743@linux.vnet.ibm.com>
In-Reply-To: <20090102125752.GA5743@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200901110108.20848.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
To: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, linux-mm@kvack.org, sfr@canb.auug.org.au, benh@kernel.crashing.org, akpm@linux-foundation.org, torvalds@linux-foundation.org, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

On Friday 02 January 2009, Kamalesh Babulal wrote:
> Hi,
> 
> 	2.6.28-git4 kernel drops to xmon with kernel expection. Similar kernel
> expection was seen next-20081230 and next-20081231 and was reported 
> earlier at http://lkml.org/lkml/2008/12/31/157

Is this a regression from 2.6.27?

Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
