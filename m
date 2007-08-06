Date: Mon, 6 Aug 2007 11:00:53 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC][PATCH 1/5] Fix hugetlb pool allocation with empty nodes
 V9
In-Reply-To: <20070806163726.GK15714@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0708061059400.24256@schroedinger.engr.sgi.com>
References: <20070806163254.GJ15714@us.ibm.com> <20070806163726.GK15714@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: anton@samba.org, lee.schermerhorn@hp.com, wli@holomorphy.com, melgor@ie.ibm.com, akpm@linux-foundation.org, linux-mm@kvack.org, agl@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Mon, 6 Aug 2007, Nishanth Aravamudan wrote:

> +	pol = mpol_new(MPOL_INTERLEAVE, &node_states[N_HIGH_MEMORY]);
> +	if (IS_ERR(pol))
> +		goto quit;


You are hardcoding a policy here. Is that really necessary? You could call 
the interleave node functions yourself to generate the node distribution. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
