Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5DNY5Po018538
	for <linux-mm@kvack.org>; Wed, 13 Jun 2007 19:34:05 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5DNWxQn528122
	for <linux-mm@kvack.org>; Wed, 13 Jun 2007 19:32:59 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5DNWxSo024804
	for <linux-mm@kvack.org>; Wed, 13 Jun 2007 19:32:59 -0400
Date: Wed, 13 Jun 2007 16:32:56 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 2/3] Fix GFP_THISNODE behavior for memoryless nodes
Message-ID: <20070613233256.GZ3798@us.ibm.com>
References: <20070612204843.491072749@sgi.com> <20070612205738.548677035@sgi.com> <1181769033.6148.116.camel@localhost> <Pine.LNX.4.64.0706131535200.32399@schroedinger.engr.sgi.com> <20070613231153.GW3798@us.ibm.com> <Pine.LNX.4.64.0706131613050.394@schroedinger.engr.sgi.com> <20070613232005.GY3798@us.ibm.com> <Pine.LNX.4.64.0706131626250.698@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0706131626250.698@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, akpm@linux-foundation.org, linux-mm@kvack.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

On 13.06.2007 [16:26:50 -0700], Christoph Lameter wrote:
> On Wed, 13 Jun 2007, Nishanth Aravamudan wrote:
> 
> > Who the heck said anything about mainline?
> 
> Well we do have discovered issues that are bugs. Handling of
> memoryless nodes is rather strange.

Without a doubt :)

Sorry, the real reason for wrapping the patches and reposting, for me,
is that we've had a lot of versions flying around, with small fixlets
here and there. I wanted to start a new thread for the 3 or so patches I
see that implement the core of dealing with memoryless nodes, and then
keep the discussion going there, but that was purely for my own sanity.

Sorry if I overreacted.

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
