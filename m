Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l76IJF78005862
	for <linux-mm@kvack.org>; Mon, 6 Aug 2007 14:19:15 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l76IJEbu081898
	for <linux-mm@kvack.org>; Mon, 6 Aug 2007 12:19:14 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l76IJD6l002669
	for <linux-mm@kvack.org>; Mon, 6 Aug 2007 12:19:14 -0600
Date: Mon, 6 Aug 2007 11:19:12 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [RFC][PATCH 1/5] Fix hugetlb pool allocation with empty nodes V9
Message-ID: <20070806181912.GS15714@us.ibm.com>
References: <20070806163254.GJ15714@us.ibm.com> <20070806163726.GK15714@us.ibm.com> <Pine.LNX.4.64.0708061059400.24256@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0708061059400.24256@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: anton@samba.org, lee.schermerhorn@hp.com, wli@holomorphy.com, melgor@ie.ibm.com, akpm@linux-foundation.org, linux-mm@kvack.org, agl@us.ibm.com
List-ID: <linux-mm.kvack.org>

On 06.08.2007 [11:00:53 -0700], Christoph Lameter wrote:
> On Mon, 6 Aug 2007, Nishanth Aravamudan wrote:
> 
> > +	pol = mpol_new(MPOL_INTERLEAVE, &node_states[N_HIGH_MEMORY]);
> > +	if (IS_ERR(pol))
> > +		goto quit;
> 
> 
> You are hardcoding a policy here. Is that really necessary? You could
> call the interleave node functions yourself to generate the node
> distribution. 

Uh, interleave_nodes() takes a policy. Hence I need a policy to use.
This was your suggestion, Christoph and I'm doing exactly what you
asked.

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
