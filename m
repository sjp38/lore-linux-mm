Date: Thu, 17 Jan 2008 07:05:51 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [BUG] at mm/slab.c:3320
In-Reply-To: <Pine.LNX.4.64.0801171634530.27536@sbz-30.cs.Helsinki.FI>
Message-ID: <Pine.LNX.4.64.0801170705210.19928@schroedinger.engr.sgi.com>
References: <20080107102301.db52ab64.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0801072131350.28725@schroedinger.engr.sgi.com>
 <20080109065015.GG7602@us.ibm.com>  <Pine.LNX.4.64.0801090949440.10163@schroedinger.engr.sgi.com>
  <20080109185859.GD11852@skywalker>  <Pine.LNX.4.64.0801091122490.11317@schroedinger.engr.sgi.com>
  <20080109214707.GA26941@us.ibm.com>  <Pine.LNX.4.64.0801091349430.12505@schroedinger.engr.sgi.com>
  <20080109221315.GB26941@us.ibm.com>  <Pine.LNX.4.64.0801091601080.14723@schroedinger.engr.sgi.com>
 <84144f020801170431l2d6d0d63i1fb7ebc5145539f4@mail.gmail.com>
 <Pine.LNX.4.64.0801170631000.19208@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0801171634530.27536@sbz-30.cs.Helsinki.FI>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka J Enberg <penberg@cs.helsinki.fi>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Nishanth Aravamudan <nacc@us.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, lee.schermerhorn@hp.com, bob.picco@hp.com, mel@skynet.ie, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 17 Jan 2008, Pekka J Enberg wrote:

> Aah, yeah, it does page_to_nid(). Thanks.
> 
> Reviewed-by: Pekka Enberg <penberg@cs.helsinki.fi>
> 
> Lets get this to Andrew or Linus for 2.6.24?

Not so fast. First we need confirmation that the patch actually fixes the 
issue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
