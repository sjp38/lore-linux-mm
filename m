Message-ID: <46EAB004.7010905@mbligh.org>
Date: Fri, 14 Sep 2007 09:00:04 -0700
From: "Martin J. Bligh" <mbligh@mbligh.org>
MIME-Version: 1.0
Subject: Re: [PATCH/RFC] Add node states sysfs class attributeS - V5
References: <20070827222912.8b364352.akpm@linux-foundation.org> <Pine.LNX.4.64.0708272235580.9834@schroedinger.engr.sgi.com> <20070827231214.99e3c33f.akpm@linux-foundation.org> <1188309928.5079.37.camel@localhost> <Pine.LNX.4.64.0708281458520.17559@schroedinger.engr.sgi.com> <29495f1d0708281513g406af15an8139df5fae20ad35@mail.gmail.com> <1188398621.5121.13.camel@localhost> <Pine.LNX.4.64.0708291039210.21184@schroedinger.engr.sgi.com> <1189518975.5036.3.camel@localhost> <20070914035058.89b13fa4.akpm@linux-foundation.org> <20070914144300.GE30407@skynet.ie>
In-Reply-To: <20070914144300.GE30407@skynet.ie>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <clameter@sgi.com>, Nish Aravamudan <nish.aravamudan@gmail.com>, y-goto@jp.fujitsu.com, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Eric Whitney <eric.whitney@hp.com>, Andy Whitcroft <apw@shadowen.org>, lethal@linux-sh.org
List-ID: <linux-mm.kvack.org>

>> So how do we get it tested with CONFIG_HIGHMEM=y?  Needs an i386
>> numa machine, yes?  Perhaps Andy or Martin can remember to do this
>> sometime, but they'll need a test plan ;)
>>
> 
> As an aside, 32 Bit NUMA usually means we turn the NUMAQ into a whipping boy
> and give the problem lip service.

The x440 should be 32-bit NUMA too if it hasn't gone up in flames yet.

> However, I'd be interested in hearing if
> superh has dependencies on 32 bit NUMA working properly, including HIGHMEM
> issues.
 >
> I've cc'd Paul Mundt. Paul, does superh use 32 bit NUMA? Is it used with
> with HIGHMEM?
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
