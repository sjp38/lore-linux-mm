Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5C2Ygcs004529
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 22:34:42 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5C2Yfgh266694
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 20:34:41 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5C2Yfsu015470
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 20:34:41 -0600
Date: Mon, 11 Jun 2007 19:34:39 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH][RFC] hugetlb: add per-node nr_hugepages sysfs attribute
Message-ID: <20070612023439.GM3798@us.ibm.com>
References: <20070611221036.GA14458@us.ibm.com> <Pine.LNX.4.64.0706111537250.20954@schroedinger.engr.sgi.com> <20070611225213.GB14458@us.ibm.com> <20070611230829.GC14458@us.ibm.com> <20070611231008.GD14458@us.ibm.com> <20070611231149.GE14458@us.ibm.com> <20070611231314.GF14458@us.ibm.com> <Pine.LNX.4.64.0706111641160.24042@schroedinger.engr.sgi.com> <20070612021950.GI3798@us.ibm.com> <Pine.LNX.4.64.0706111921540.25134@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0706111921540.25134@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: lee.schermerhorn@hp.com, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On 11.06.2007 [19:22:43 -0700], Christoph Lameter wrote:
> On Mon, 11 Jun 2007, Nishanth Aravamudan wrote:
> 
> > Ok, if I do that, would you prefer I just add callbacks into hugetlb
> > code for register_node() and unregister_node() that are no-ops if
> > !CONFIG_HUGETLB_PAGE? That is, rather than
> > 
> > 	sysdev_remove_file(&node->sysdev, &attr_nr_hugepages);
> > 
> > just call something like
> > 
> > 	hugetlb_unregister_node()
> > 
> > ? And similar for register? Otherwise, there are still going to be
> > ifdefs for the remove and add calls.
> 
> Sounds good. Lets see the patch.

Of course, just wanted to make sure were on the same page.

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
