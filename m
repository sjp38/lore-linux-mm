Message-ID: <466D7EF2.3080504@redhat.com>
Date: Mon, 11 Jun 2007 12:57:22 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 15 of 16] limit reclaim if enough pages have been freed
References: <31ef5d0bf924fb47da14.1181332993@v2.random> <466C32F2.9000306@redhat.com> <20070610173221.GB7443@v2.random> <466C3A60.6080403@redhat.com> <Pine.LNX.4.64.0706110922420.15489@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0706110922420.15489@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org, Larry Woodman <lwoodman@redhat.com>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Sun, 10 Jun 2007, Rik van Riel wrote:
> 
>> Andrea Arcangeli wrote:
>>> On Sun, Jun 10, 2007 at 01:20:50PM -0400, Rik van Riel wrote:
>>>> code simultaneously, all starting out at priority 12 and
>>>> not freeing anything until they all get to much lower
>>>> priorities.
>>> BTW, this reminds me that I've been wondering if 2**12 is a too small
>>> fraction of the lru to start the scan with.
>> If the system has 1 TB of RAM, it's probably too big
>> of a fraction :)
>>
>> We need something smarter.
> 
> Well this value is depending on a nodes memory not on the systems 
> total memory. So I think we are fine. 1TB systems (at least ours) are 
> comprised of nodes with 4GB/8GB/16GB of memory.

Yours are fine, because currently the very large system
customers tend to run fine tuned workloads.

We are seeing some other users throwing random workloads
at systems with 256GB of RAM in a single zone.  General
purpose computing is moving up, VM explosions are becoming
more spectacular :)

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
