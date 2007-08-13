Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7DHv8DZ031214
	for <linux-mm@kvack.org>; Mon, 13 Aug 2007 13:57:08 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l7DHtnqk522148
	for <linux-mm@kvack.org>; Mon, 13 Aug 2007 13:55:49 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7DHtmRt014991
	for <linux-mm@kvack.org>; Mon, 13 Aug 2007 13:55:49 -0400
Subject: Re: [RFC][PATCH 4/4] hugetlb: add per-node nr_hugepages sysfs
	attribute
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20070809005217.GK16588@us.ibm.com>
References: <20070809004726.GH16588@us.ibm.com>
	 <20070809004914.GI16588@us.ibm.com> <20070809005128.GJ16588@us.ibm.com>
	 <20070809005217.GK16588@us.ibm.com>
Content-Type: text/plain
Date: Mon, 13 Aug 2007 10:55:46 -0700
Message-Id: <1187027746.2521.48.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: clameter@sgi.com, anton@samba.org, lee.schermerhorn@hp.com, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2007-08-08 at 17:52 -0700, Nishanth Aravamudan wrote:
> 
> +#ifdef CONFIG_NUMA
> +int hugetlb_register_node(struct node *);
> +void hugetlb_unregister_node(struct node *);
> +#else
> +#define hugetlb_register_node(node)            0
> +#define hugetlb_unregister_node(node)          ((void)0)
> +#endif 

This is to keep someone from doing:

	ret = hugetlb_unregister_node(node);

?

I think it's a little more standard to do:

	#define hugetlb_unregister_node(node)          do {} while(0)

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
