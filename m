Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5C2JrfA000914
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 22:19:53 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5C2Jrpr167322
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 20:19:53 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5C2JqJr021026
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 20:19:53 -0600
Date: Mon, 11 Jun 2007 19:19:50 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH][RFC] hugetlb: add per-node nr_hugepages sysfs attribute
Message-ID: <20070612021950.GI3798@us.ibm.com>
References: <20070611202728.GD9920@us.ibm.com> <Pine.LNX.4.64.0706111417540.20454@schroedinger.engr.sgi.com> <20070611221036.GA14458@us.ibm.com> <Pine.LNX.4.64.0706111537250.20954@schroedinger.engr.sgi.com> <20070611225213.GB14458@us.ibm.com> <20070611230829.GC14458@us.ibm.com> <20070611231008.GD14458@us.ibm.com> <20070611231149.GE14458@us.ibm.com> <20070611231314.GF14458@us.ibm.com> <Pine.LNX.4.64.0706111641160.24042@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0706111641160.24042@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: lee.schermerhorn@hp.com, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On 11.06.2007 [16:42:33 -0700], Christoph Lameter wrote:
> On Mon, 11 Jun 2007, Nishanth Aravamudan wrote:
> 
> >  }
> >  static SYSDEV_ATTR(distance, S_IRUGO, node_read_distance, NULL);
> >  
> > +#ifdef CONFIG_HUGETLB_PAGE
> > +static SYSDEV_ATTR(nr_hugepages, S_IRUGO | S_IWUSR,
> > +				hugetlb_read_nr_hugepages_node,
> > +				hugetlb_write_nr_hugepages_node);
> > +#endif
> 
> Move the above to hugetlb.c?

Ok, if I do that, would you prefer I just add callbacks into hugetlb
code for register_node() and unregister_node() that are no-ops if
!CONFIG_HUGETLB_PAGE? That is, rather than

	sysdev_remove_file(&node->sysdev, &attr_nr_hugepages);

just call something like

	hugetlb_unregister_node()

? And similar for register? Otherwise, there are still going to be
ifdefs for the remove and add calls.

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
