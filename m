Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j35J1oua086638
	for <linux-mm@kvack.org>; Tue, 5 Apr 2005 15:01:50 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j35J1nHO167488
	for <linux-mm@kvack.org>; Tue, 5 Apr 2005 13:01:49 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id j35J1nUL020297
	for <linux-mm@kvack.org>; Tue, 5 Apr 2005 13:01:49 -0600
Subject: Re: [ckrm-tech] Re: [PATCH 3/6] CKRM: Add limit support for mem
	controller
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20050405182620.GF32645@chandralinux.beaverton.ibm.com>
References: <20050402031346.GD23284@chandralinux.beaverton.ibm.com>
	 <1112623850.24676.8.camel@localhost>
	 <20050405174239.GD32645@chandralinux.beaverton.ibm.com>
	 <1112723942.19430.77.camel@localhost>
	 <20050405182620.GF32645@chandralinux.beaverton.ibm.com>
Content-Type: text/plain
Date: Tue, 05 Apr 2005 12:01:45 -0700
Message-Id: <1112727705.19430.121.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chandra Seetharaman <sekharan@us.ibm.com>
Cc: ckrm-tech@lists.sourceforge.net, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2005-04-05 at 11:26 -0700, Chandra Seetharaman wrote:
> On Tue, Apr 05, 2005 at 10:59:02AM -0700, Dave Hansen wrote:
> > On Tue, 2005-04-05 at 10:42 -0700, Chandra Seetharaman wrote:
> > > On Mon, Apr 04, 2005 at 07:10:50AM -0700, Dave Hansen wrote: 
> > > > What does "impl" stand for, anyway?  implied?  implicit? implemented?
> > > 
> > > I meant implicit... you can also say implied.... will add in comments to
> > > the dats structure definition.
> > 
> > How about changing the name of the structure member?  Comments suck.
> 
> you mean explicit name like implicit_guarantee ? if comments suck, IMHO,
> impl_guar is good enough an option for a field that holds implicit
> guarantee.

I think you possibly suffer from an a case of ibmersdontlikevowelsitis
which seems to be endemic to our company.  In case you're wondering,
Linus already found our missing vowels:

	http://www.ussg.iu.edu/hypermail/linux/kernel/0110.1/1294.html

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
