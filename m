Message-ID: <43FA8690.3070608@yahoo.com.au>
Date: Tue, 21 Feb 2006 14:18:40 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC] 0/4 Migration Cache Overview
References: <1140190593.5219.22.camel@localhost.localdomain>  <Pine.LNX.4.64.0602170816530.30999@schroedinger.engr.sgi.com> <1140195598.5219.77.camel@localhost.localdomain> <Pine.LNX.4.64.0602170906030.31408@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0602170906030.31408@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm <linux-mm@kvack.org>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Fri, 17 Feb 2006, Lee Schermerhorn wrote:
> 
> 
>>>Could add a justification of this feature? What is the benefit of having a 
>>>migration cache instead of using swap pte (current migration is not really 
>>>using swap space per se)?
>>
>>I think Marcello covered that in his original posts, which I linked.  
>>I can go back and extract his arguments.  My primary interest is for
>>"lazy page migration" where anon pages can hang around the the cache
>>until the task faults them in [possibly migrating] or exits, if ever.
>>I think the desire to avoid using swap for this case is even stronger.
> 
> 
> I am bit confused. A task faults in a page from the migration cache? Isnt 
> this swap behavior? I thought the migration cache was just to avoid using
> swap page numbers for the intermediate pte values during migration?
> 

It really does seem like the swapcache does everything required. The
swapcache is just a pagecache mapping for anonymous pages. Adding an
extra "somethingcache" for anonymous pages shouldn't add anything. I
guess I'm missing something as well.

> You are moving the page when it is faulted in?
> 
> Including Marcelo's rationale may help understanding here. I read it a 
> while back but I do not remember the details. Please give us an overview.
> 

Yes, this should always be done in patches themselves rather than
linking to other posts (within reason), because it gives you something
to reply to and it gets into the changeset history.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
