Date: Mon, 11 Jun 2007 17:43:52 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH][RFC] hugetlb: add per-node nr_hugepages sysfs attribute
In-Reply-To: <20070612001945.GK14458@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0706111743120.24389@schroedinger.engr.sgi.com>
References: <20070611202728.GD9920@us.ibm.com>
 <Pine.LNX.4.64.0706111417540.20454@schroedinger.engr.sgi.com>
 <20070611221036.GA14458@us.ibm.com> <Pine.LNX.4.64.0706111537250.20954@schroedinger.engr.sgi.com>
 <20070611225213.GB14458@us.ibm.com> <20070611230829.GC14458@us.ibm.com>
 <20070611231008.GD14458@us.ibm.com> <20070611231149.GE14458@us.ibm.com>
 <20070611231314.GF14458@us.ibm.com> <Pine.LNX.4.64.0706111641160.24042@schroedinger.engr.sgi.com>
 <20070612001945.GK14458@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: lee.schermerhorn@hp.com, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On Mon, 11 Jun 2007, Nishanth Aravamudan wrote:

> Also, I don't really see where else a per-node attribute should go other
> than /sys/devices/system/node/nodeX... Did you have a better location in
> mind?

No I think this is okay but doing so sets a precedent. If you do this then 
others will add more config stuff to that directory. So we need the 
feedback from others.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
