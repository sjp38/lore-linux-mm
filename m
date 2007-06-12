Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5C3VcH3020026
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 23:31:38 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5C3VcUr531406
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 23:31:38 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5C3VbA7022395
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 23:31:38 -0400
Date: Mon, 11 Jun 2007 20:31:35 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH] populated_map: fix !NUMA case, remove comment
Message-ID: <20070612033135.GS3798@us.ibm.com>
References: <20070611234155.GG14458@us.ibm.com> <Pine.LNX.4.64.0706111642450.24042@schroedinger.engr.sgi.com> <20070612000705.GH14458@us.ibm.com> <Pine.LNX.4.64.0706111740280.24389@schroedinger.engr.sgi.com> <20070612020257.GF3798@us.ibm.com> <Pine.LNX.4.64.0706111919450.25134@schroedinger.engr.sgi.com> <20070612023209.GJ3798@us.ibm.com> <Pine.LNX.4.64.0706111953220.25390@schroedinger.engr.sgi.com> <20070612032055.GQ3798@us.ibm.com> <Pine.LNX.4.64.0706112021180.25705@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0706112021180.25705@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: lee.schermerhorn@hp.com, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 11.06.2007 [20:21:58 -0700], Christoph Lameter wrote:
> On Mon, 11 Jun 2007, Nishanth Aravamudan wrote:
> 
> > > I am not sure what you are up to. Just make sure that the changes are
> > > minimal. Look in the source code for other examples on how !NUMA
> > > situations were handled.
> > 
> > I swear I'm trying to make the code do the right thing, and understand
> > the NUMA intricacies better. Sorry for the flood of e-mails and such. I
> > asked about specific other cases because they are used in !NUMA
> > situations too and I wasn't sure why node_populated_map should be
> > different.
> > 
> > But ok, I will rely on the source to be correct and make my changelog
> > indicate where I got the ideas from.
> 
> Ok. I just hope this crash course in Linux NUMA is useful and you keep on 
> working on NUMA....

I'll try, at least.

Thanks for the patience!

-Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
