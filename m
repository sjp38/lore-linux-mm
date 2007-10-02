Date: Tue, 2 Oct 2007 16:39:48 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 2/4] hugetlb: fix pool allocation with empty nodes
In-Reply-To: <20071002224719.GB13137@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0710021639120.32409@schroedinger.engr.sgi.com>
References: <20070906182134.GA7779@us.ibm.com> <20070906182430.GB7779@us.ibm.com>
 <Pine.LNX.4.64.0709141152250.17038@schroedinger.engr.sgi.com>
 <20071002224719.GB13137@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: anton@samba.org, wli@holomorphy.com, agl@us.ibm.com, lee.schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2 Oct 2007, Nishanth Aravamudan wrote:

> A node has its bit in N_HIGH_MEMORY set if it has any memory regardless
> of t type of memory.  If a node has memory then it has at least one zone
> defined in its pgdat structure that is located in the pgdat itself.
> 
> And, indeed, if CONFIG_HIGHMEM is off, N_HIGH_MEMORY == N_NORMAL_MEMORY.
> 
> So I think I'm ok?

Yes that reasoning sounds sane.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
