Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7MLHUkR015791
	for <linux-mm@kvack.org>; Wed, 22 Aug 2007 17:17:30 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7MLHTrH202688
	for <linux-mm@kvack.org>; Wed, 22 Aug 2007 15:17:29 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7MLHTlD021875
	for <linux-mm@kvack.org>; Wed, 22 Aug 2007 15:17:29 -0600
Date: Wed, 22 Aug 2007 14:17:28 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [RFC][PATCH 4/4] hugetlb: add per-node nr_hugepages sysfs attribute
Message-ID: <20070822211728.GA5542@us.ibm.com>
References: <20070809004726.GH16588@us.ibm.com> <20070809004914.GI16588@us.ibm.com> <20070809005128.GJ16588@us.ibm.com> <20070809005217.GK16588@us.ibm.com> <1187027746.2521.48.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1187027746.2521.48.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: clameter@sgi.com, anton@samba.org, lee.schermerhorn@hp.com, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 13.08.2007 [10:55:46 -0700], Dave Hansen wrote:
> On Wed, 2007-08-08 at 17:52 -0700, Nishanth Aravamudan wrote:
> > 
> > +#ifdef CONFIG_NUMA
> > +int hugetlb_register_node(struct node *);
> > +void hugetlb_unregister_node(struct node *);
> > +#else
> > +#define hugetlb_register_node(node)            0
> > +#define hugetlb_unregister_node(node)          ((void)0)
> > +#endif 
> 
> This is to keep someone from doing:
> 
> 	ret = hugetlb_unregister_node(node);
> 
> ?
> 
> I think it's a little more standard to do:
> 
> 	#define hugetlb_unregister_node(node)          do {} while(0)

That's a good point. Now that I'm back from vacation, I'll make this
adjustment.

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
