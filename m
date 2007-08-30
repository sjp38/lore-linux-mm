Date: Thu, 30 Aug 2007 11:20:16 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC] Add node states sysfs class attributeS - V4
In-Reply-To: <29495f1d0708300944o9aafdc5ob9dd30a687402ab@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0708301119320.7975@schroedinger.engr.sgi.com>
References: <200708242228.l7OMS5fU017948@imap1.linux-foundation.org>
 <20070827222912.8b364352.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0708272235580.9834@schroedinger.engr.sgi.com>
 <20070827231214.99e3c33f.akpm@linux-foundation.org>  <1188309928.5079.37.camel@localhost>
  <Pine.LNX.4.64.0708281458520.17559@schroedinger.engr.sgi.com>
 <29495f1d0708281513g406af15an8139df5fae20ad35@mail.gmail.com>
 <1188398621.5121.13.camel@localhost>  <Pine.LNX.4.64.0708291039210.21184@schroedinger.engr.sgi.com>
  <1188487157.5794.40.camel@localhost> <29495f1d0708300944o9aafdc5ob9dd30a687402ab@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nish Aravamudan <nish.aravamudan@gmail.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, mel@skynet.ie, y-goto@jp.fujitsu.com, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Thu, 30 Aug 2007, Nish Aravamudan wrote:

> I feel like we should keep them separate. They are distinct in the
> kernel for a reason, right? Do we perhaps actually want
> 
> has_normal_memory
> has_highmem_memory
> has_memory

No. We just want the norma and the highmem mask. Lets keep them 1-1 to the 
actual nodemask array and keep the same names too to reduce confusion.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
