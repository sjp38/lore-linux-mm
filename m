Date: Wed, 25 Aug 2004 15:02:14 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [Bug 3268] New: Lowmemory exhaustion problem with v2.6.8.1-mm4	16gb
Message-ID: <5120000.1093471334@[10.10.2.4]>
In-Reply-To: <1093470564.5677.1920.camel@knk>
References: <Pine.LNX.4.44.0408252104540.2664-100000@localhost.localdomain> <1093470564.5677.1920.camel@knk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: keith <kmannth@us.ibm.com>, Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> Well, by default it does give you a maximum number of inodes for tmpfs:
>> which at 16GB of RAM (in 4KB pages: odd that that factors in, but I've
>> no great urge to depart from existing defaults except where it's buggy)
>> would give you 2M inodes.  But since each might roughly be expected to
>> consume 1KB (a shmem_inode, a dentry, a longer name, a radix node) of
>> low memory, we'd want 2GB of lowmem to support all those: too much.
> 
> I think there is a need for a hard upper limit to the number of inodes
> tmpfs can use.  With this system I can have 32gb of memory and I also
> have a 64gb(i386) system. tempfs sizes above 15=g are definitely
> possible.  What about a 40gig tmpfs.... 

The problem is ... how much mem are you willing to lose? Anything that's
unshrinkable is very, very dangerous ... whatever the limit you put on it.
But I agree, it'd be better than the current.

>> So, how well does the patch below work for you, if you leave nr_inodes
>> to its default?  Carry on setting size=15G, that should be okay; but
>> I don't think the kernel should stop you if you insist on setting
>> nr_inodes to something unfortunate like 10M.  "df -i" will show
>> how many inodes it's actually giving you by default.
> 
> I was wondering how to do that thanks. 
> With the patch I only get 82294 inodes.  Hmmmm.... I don't have any
> lowmem issues but I can't create too many files.  

Well, you have to pick one or the other ;-)

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
