Date: Mon, 6 Aug 2007 11:37:35 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC][PATCH 1/5] Fix hugetlb pool allocation with empty nodes
 V9
In-Reply-To: <20070806181912.GS15714@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0708061136260.3152@schroedinger.engr.sgi.com>
References: <20070806163254.GJ15714@us.ibm.com> <20070806163726.GK15714@us.ibm.com>
 <Pine.LNX.4.64.0708061059400.24256@schroedinger.engr.sgi.com>
 <20070806181912.GS15714@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: anton@samba.org, lee.schermerhorn@hp.com, wli@holomorphy.com, melgor@ie.ibm.com, akpm@linux-foundation.org, linux-mm@kvack.org, agl@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Mon, 6 Aug 2007, Nishanth Aravamudan wrote:

> Uh, interleave_nodes() takes a policy. Hence I need a policy to use.
> This was your suggestion, Christoph and I'm doing exactly what you
> asked.

That would make sense if the policy can be overridden. You may be able to 
avoid exporting mpol_new by callig just the functions that generate the 
interleave nodes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
