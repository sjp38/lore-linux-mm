Message-ID: <430E93AA.50901@andrew.cmu.edu>
Date: Thu, 25 Aug 2005 23:59:38 -0400
From: Rahul Iyer <rni@andrew.cmu.edu>
MIME-Version: 1.0
Subject: Re: Zoned CART
References: <1123857429.14899.59.camel@twins>  <1124024312.30836.26.camel@twins> <1124141492.15180.22.camel@twins>  <43024435.90503@andrew.cmu.edu>  <Pine.LNX.4.62.0508161318420.7906@schroedinger.engr.sgi.com> <1125009555.20161.33.camel@twins> <Pine.LNX.4.62.0508251657530.8955@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0508251657530.8955@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:

>On Fri, 26 Aug 2005, Peter Zijlstra wrote:
>
>  
>
>>This is with a rahul's 3 list approach:
>>  active_list <-> T1, 
>>  active_longterm <-> T2
>>    
>>
>
>longterm == T2? That wont work. longterm (L) is composed of T2 and a 
>subset of T1.
>
>  
>
This is probably named a bit wrong... active_longterm is meant to be the 
T2 list, not the list of all longterm pages. The LongTerm bit in the 
page flags defines whether the page is longterm or not.
thanks
rahul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
