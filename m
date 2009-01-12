Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 032A36B004F
	for <linux-mm@kvack.org>; Mon, 12 Jan 2009 03:08:05 -0500 (EST)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [BUG] 2.6.28-git-4 - powerpc - kernel expection 'c01 at .kernel_thread'
Date: Mon, 12 Jan 2009 09:07:19 +0100
References: <20090102125752.GA5743@linux.vnet.ibm.com> <200901110108.20848.rjw@sisk.pl> <20090112072132.GA8409@linux.vnet.ibm.com>
In-Reply-To: <20090112072132.GA8409@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200901120907.20418.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
To: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, linux-mm@kvack.org, sfr@canb.auug.org.au, benh@kernel.crashing.org, akpm@linux-foundation.org, torvalds@linux-foundation.org, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

On Monday 12 January 2009, Kamalesh Babulal wrote:
> * Rafael J. Wysocki <rjw@sisk.pl> [2009-01-11 01:08:19]:
> 
> > On Friday 02 January 2009, Kamalesh Babulal wrote:
> > > Hi,
> > > 
> > > 	2.6.28-git4 kernel drops to xmon with kernel expection. Similar kernel
> > > expection was seen next-20081230 and next-20081231 and was reported 
> > > earlier at http://lkml.org/lkml/2008/12/31/157
> > 
> > Is this a regression from 2.6.27?
> > 
> > Rafael
> >
> 
> This is not a regression from 2.6.27, this expection was first seen 
> next-20081230 patches and then was introduced into 2.6.28-git4 and is 
> reproducible with 2.6.28-rc1 kernel.

Presumably you meant 2.6.29-rc1 ?  In which case it would be a regression from
2.6.28 .  Please confirm.

Thanks,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
