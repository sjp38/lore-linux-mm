Date: Tue, 12 Jun 2007 13:03:01 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH v2] Add populated_map to account for memoryless nodes
In-Reply-To: <20070612200012.GE3798@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0706121302320.31428@schroedinger.engr.sgi.com>
References: <20070611202728.GD9920@us.ibm.com>
 <Pine.LNX.4.64.0706111417540.20454@schroedinger.engr.sgi.com>
 <20070611221036.GA14458@us.ibm.com> <Pine.LNX.4.64.0706111537250.20954@schroedinger.engr.sgi.com>
 <1181657940.5592.19.camel@localhost> <Pine.LNX.4.64.0706121143530.30754@schroedinger.engr.sgi.com>
 <1181675840.5592.123.camel@localhost> <Pine.LNX.4.64.0706121220580.3240@schroedinger.engr.sgi.com>
 <20070612194951.GC3798@us.ibm.com> <Pine.LNX.4.64.0706121250430.7983@schroedinger.engr.sgi.com>
 <20070612200012.GE3798@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 12 Jun 2007, Nishanth Aravamudan wrote:

> SERIOUSLY!? After saying that node_populated_map should be NUMA-only
> over and over, you made it global here :-P

yeah looking at it: The nodemask_t becomes very small so its not worth it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
