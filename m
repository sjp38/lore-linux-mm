Date: Fri, 29 Jun 2007 07:18:17 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC 0/11] Shared Policy Overview
In-Reply-To: <1183123347.5037.17.camel@localhost>
Message-ID: <Pine.LNX.4.64.0706290715560.14268@schroedinger.engr.sgi.com>
References: <20070625195224.21210.89898.sendpatchset@localhost>
 <1182968078.4948.30.camel@localhost>  <Pine.LNX.4.64.0706271427400.31227@schroedinger.engr.sgi.com>
  <200706280001.16383.ak@suse.de> <1183038137.5697.16.camel@localhost>
 <Pine.LNX.4.64.0706281835270.9573@schroedinger.engr.sgi.com>
 <1183123347.5037.17.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andi Kleen <ak@suse.de>, "Paul E. McKenney" <paulmck@us.ibm.com>, linux-mm@kvack.org, akpm@linux-foundation.org, nacc@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Fri, 29 Jun 2007, Lee Schermerhorn wrote:

> I'm not sure what you mean by "rationale for this patchset" in the
> context of this reference counting patch.  We've already gone over the
> rationale for shared policy on shared file mappings--over and over...

Yes and its still not clear to me what the point is. I think sharing 
policies that have so far per process semantics wil break things and cause 
a lot of difficulty in the future.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
