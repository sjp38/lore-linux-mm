Message-ID: <45E8AB36.3030104@redhat.com>
Date: Fri, 02 Mar 2007 17:54:46 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: The performance and behaviour of the anti-fragmentation related
 patches
References: <20070301101249.GA29351@skynet.ie>	<20070301160915.6da876c5.akpm@linux-foundation.org>	<45E842F6.5010105@redhat.com>	<20070302085838.bcf9099e.akpm@linux-foundation.org>	<Pine.LNX.4.64.0703020919350.16719@schroedinger.engr.sgi.com>	<20070302093501.34c6ef2a.akpm@linux-foundation.org>	<45E8624E.2080001@redhat.com>	<20070302100619.cec06d6a.akpm@linux-foundation.org>	<Pine.LNX.4.64.0703021012170.17676@schroedinger.engr.sgi.com>	<45E86BA0.50508@redhat.com>	<20070302211207.GJ10643@holomorphy.com>	<45E894D7.2040309@redhat.com>	<20070302135243.ada51084.akpm@linux-foundation.org>	<45E89F1E.8020803@redhat.com> <20070302142256.0127f5ac.akpm@linux-foundation.org> <45E8A677.7000205@redhat.com> <45E8AA64.3050506@mbligh.org>
In-Reply-To: <45E8AA64.3050506@mbligh.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Bligh <mbligh@mbligh.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Bill Irwin <bill.irwin@oracle.com>, Christoph Lameter <clameter@engr.sgi.com>, Mel Gorman <mel@skynet.ie>, npiggin@suse.de, mingo@elte.hu, jschopp@austin.ibm.com, arjan@infradead.org, torvalds@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Martin Bligh wrote:
>>> None of this is going anywhere, is is it?
>>
>> I will test my changes before I send them to you, but I cannot
>> promise you that you'll have the computers or software needed
>> to reproduce the problems.  I doubt I'll have full time access
>> to such systems myself, either.
>>
>> 32GB is pretty much the minimum size to reproduce some of these
>> problems. Some workloads may need larger systems to easily trigger
>> them.
> 
> We can find a 32GB system here pretty easily to test things on if
> need be.  Setting up large commercial databases is much harder.

That's my problem, too.

There does not seem to exist any single set of test cases that
accurately predicts how the VM will behave with customer
workloads.

The one thing I can do relatively easily is go through a few
hundred bugzillas and figure out what kinds of problems have
been plaguing the VM consistently over the last few years.
I just finished doing that, and am trying to come up with
fixes for the problems that just don't seem to be easily
fixable with bandaids...

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
