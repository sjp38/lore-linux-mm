Date: Wed, 13 Jun 2007 16:26:15 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] populated_map: fix !NUMA case, remove comment
In-Reply-To: <20070613231825.GX3798@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0706131625530.698@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0706121150220.30754@schroedinger.engr.sgi.com>
 <1181677473.5592.149.camel@localhost> <Pine.LNX.4.64.0706121245200.7983@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0706121257290.7983@schroedinger.engr.sgi.com>
 <20070612200125.GG3798@us.ibm.com> <1181748606.6148.19.camel@localhost>
 <20070613175802.GP3798@us.ibm.com> <Pine.LNX.4.64.0706131549480.32399@schroedinger.engr.sgi.com>
 <20070613230906.GV3798@us.ibm.com> <Pine.LNX.4.64.0706131609370.394@schroedinger.engr.sgi.com>
 <20070613231825.GX3798@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 13 Jun 2007, Nishanth Aravamudan wrote:

> Well...maybe we can do better by just adding another GFP flag?
> 
> GFP_ONLYTHISNODE?
> 
> THISNODE has the current semantics, that the "closest" node is
> preferred, which may be local, and it will succeed if memory exists
> somewhere for the allocation you want (I think).

No we want one GFP_THISNODE working in a consistent way.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
