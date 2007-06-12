Date: Mon, 11 Jun 2007 19:22:43 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH][RFC] hugetlb: add per-node nr_hugepages sysfs attribute
In-Reply-To: <20070612021950.GI3798@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0706111921540.25134@schroedinger.engr.sgi.com>
References: <20070611202728.GD9920@us.ibm.com>
 <Pine.LNX.4.64.0706111417540.20454@schroedinger.engr.sgi.com>
 <20070611221036.GA14458@us.ibm.com> <Pine.LNX.4.64.0706111537250.20954@schroedinger.engr.sgi.com>
 <20070611225213.GB14458@us.ibm.com> <20070611230829.GC14458@us.ibm.com>
 <20070611231008.GD14458@us.ibm.com> <20070611231149.GE14458@us.ibm.com>
 <20070611231314.GF14458@us.ibm.com> <Pine.LNX.4.64.0706111641160.24042@schroedinger.engr.sgi.com>
 <20070612021950.GI3798@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: lee.schermerhorn@hp.com, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On Mon, 11 Jun 2007, Nishanth Aravamudan wrote:

> Ok, if I do that, would you prefer I just add callbacks into hugetlb
> code for register_node() and unregister_node() that are no-ops if
> !CONFIG_HUGETLB_PAGE? That is, rather than
> 
> 	sysdev_remove_file(&node->sysdev, &attr_nr_hugepages);
> 
> just call something like
> 
> 	hugetlb_unregister_node()
> 
> ? And similar for register? Otherwise, there are still going to be
> ifdefs for the remove and add calls.

Sounds good. Lets see the patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
