Date: Mon, 11 Jun 2007 20:53:31 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH v6][RFC] Fix hugetlb pool allocation with empty nodes
In-Reply-To: <20070612035324.GB11781@holomorphy.com>
Message-ID: <Pine.LNX.4.64.0706112053190.25967@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0706111417540.20454@schroedinger.engr.sgi.com>
 <20070611221036.GA14458@us.ibm.com> <Pine.LNX.4.64.0706111537250.20954@schroedinger.engr.sgi.com>
 <20070611225213.GB14458@us.ibm.com> <20070611230829.GC14458@us.ibm.com>
 <20070611231008.GD14458@us.ibm.com> <Pine.LNX.4.64.0706111615450.23857@schroedinger.engr.sgi.com>
 <20070612001542.GJ14458@us.ibm.com> <20070612034407.GB11773@holomorphy.com>
 <Pine.LNX.4.64.0706112050070.25900@schroedinger.engr.sgi.com>
 <20070612035324.GB11781@holomorphy.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, lee.schermerhorn@hp.com, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 11 Jun 2007, William Lee Irwin III wrote:

> On Mon, Jun 11, 2007 at 08:50:49PM -0700, Christoph Lameter wrote:
> > Each task already has a next node field. Just use that.
> 
> That's new. It sounds convenient.

No its ancient.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
