Message-ID: <46C650B8.6040004@google.com>
Date: Fri, 17 Aug 2007 18:51:52 -0700
From: Ethan Solomita <solo@google.com>
MIME-Version: 1.0
Subject: Re: cpusets vs. mempolicy and how to get interleaving
References: <46C63BDE.20602@google.com> <Pine.LNX.4.64.0708171805340.15278@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0708171805340.15278@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Paul Jackson <pj@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Fri, 17 Aug 2007, Ethan Solomita wrote:
> 
>> 	Ideally, we want a task to express its preference for interleaved
>> memory allocations without having to provide a list of nodes. The kernel will
>> automatically round-robin amongst the task's mems_allowed.
> 
> You can do that by writing 1 to /dev/cpuset/<cpuset>/memory_spread_page

	Sorry, also noticed that the above doesn't affect anonymous pages, just 
page cache, and we'd want interleaved anonymous pages.
	-- Ethan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
