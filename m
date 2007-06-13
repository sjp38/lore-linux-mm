Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5DNK8Sd012215
	for <linux-mm@kvack.org>; Wed, 13 Jun 2007 19:20:08 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5DNK8Ic394974
	for <linux-mm@kvack.org>; Wed, 13 Jun 2007 19:20:08 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5DNK72F012600
	for <linux-mm@kvack.org>; Wed, 13 Jun 2007 19:20:07 -0400
Date: Wed, 13 Jun 2007 16:20:05 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 2/3] Fix GFP_THISNODE behavior for memoryless nodes
Message-ID: <20070613232005.GY3798@us.ibm.com>
References: <20070612204843.491072749@sgi.com> <20070612205738.548677035@sgi.com> <1181769033.6148.116.camel@localhost> <Pine.LNX.4.64.0706131535200.32399@schroedinger.engr.sgi.com> <20070613231153.GW3798@us.ibm.com> <Pine.LNX.4.64.0706131613050.394@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0706131613050.394@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, akpm@linux-foundation.org, linux-mm@kvack.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

On 13.06.2007 [16:15:24 -0700], Christoph Lameter wrote:
> On Wed, 13 Jun 2007, Nishanth Aravamudan wrote:
> 
> > I would like to roll up the patches and small fixes into a set of 4 or 5
> > patches that Andrew can pick up, so once this is all stable, I'll post a
> > fresh series. Sound good, Andrew?
> 
> NACK. This patchset is not ready for any inclusion and nothing like
> that should go into 2.6.22. We first need to assess the breakage that
> results if GFP_THISNODE now returns NULL for memoryless nodes. So far
> GFP_THISNODE returns memory on the nearest node and that seems to make
> lots of things keep working.

Who the heck said anything about mainline?

See my other reply for discussing GFP_THISNODE.

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
