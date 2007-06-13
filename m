Message-ID: <466FB590.7080201@shadowen.org>
Date: Wed, 13 Jun 2007 10:14:56 +0100
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: [patch 1/3] NUMA: introduce node_memory_map
References: <20070612204843.491072749@sgi.com> <20070612205738.309078596@sgi.com> <alpine.DEB.0.99.0706121401060.5104@chino.kir.corp.google.com> <Pine.LNX.4.64.0706121407070.1850@schroedinger.engr.sgi.com> <alpine.DEB.0.99.0706121409170.5104@chino.kir.corp.google.com> <20070612213612.GH3798@us.ibm.com>
In-Reply-To: <20070612213612.GH3798@us.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: David Rientjes <rientjes@google.com>, Christoph Lameter <clameter@sgi.com>, akpm@linux-foundation.org, linux-mm@kvack.org, ak@suse.de, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

Nishanth Aravamudan wrote:
> On 12.06.2007 [14:10:44 -0700], David Rientjes wrote:
>> On Tue, 12 Jun 2007, Christoph Lameter wrote:
>>
>>> On Tue, 12 Jun 2007, David Rientjes wrote:
>>>
>>>>>   * int node_online(node)		Is some node online?
>>>>>   * int node_possible(node)		Is some node possible?
>>>>> + * int node_memory(node)		Does a node have memory?
>>>>>   *
>>>> This name doesn't make sense; wouldn't node_has_memory() be better?
>>> node_set_has_memory and node_clear_has_memory sounds a bit strange.
>>>
>> This will probably be one of those things that people see in the
>> source and have to look up everytime.  node_has_memory() is
>> straight-forward and to the point.
> 
> Indeed, I did and (I like to think) I helped write the patches :)
> 
> Why not just make the boolean sensible?
> 
> We can keep
> 
> node_set_memory()
> node_clear_memory()

node_clear_memory() sounds like something to memset all of that node's
memory or something.

> but change node_memory() to node_has_memory() ?

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
