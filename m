Date: Tue, 25 Mar 2008 16:22:44 -0700 (PDT)
Message-Id: <20080325.162244.61337214.davem@davemloft.net>
Subject: Re: larger default page sizes...
From: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0803251045510.16206@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0803241402060.7762@schroedinger.engr.sgi.com>
	<20080324.144356.104645106.davem@davemloft.net>
	<Pine.LNX.4.64.0803251045510.16206@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Christoph Lameter <clameter@sgi.com>
Date: Tue, 25 Mar 2008 10:48:19 -0700 (PDT)
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

> On Mon, 24 Mar 2008, David Miller wrote:
> 
> > There are ways to get large pages into the process address space for
> > compute bound tasks, without suffering the well known negative side
> > effects of using larger pages for everything.
> 
> These hacks have limitations. F.e. they do not deal with I/O and 
> require application changes.

Transparent automatic hugepages are definitely doable, I don't know
why you think this requires application changes.

People want these larger pages for HPC apps.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
