Date: Wed, 23 Apr 2003 07:25:58 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: 2.5.68-mm2
Message-ID: <13090000.1051107956@[10.10.2.4]>
In-Reply-To: <200304230808.25387.tomlins@cam.org>
References: <20030423012046.0535e4fd.akpm@digeo.com>
 <200304230808.25387.tomlins@cam.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>, Andrew Morton <akpm@digeo.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> As far as I see it there are two problems that objrmap/shpte/pgcl try to
> solve. One is low memory pte useage, the second being to reduce the rmap
> fork overhead.

As Bill said, I'd leave pgcl out of this one.
 
> objrmap helps in both cases but has problem with truncate and intoduces a
> O(n^2) search into the the vm.

you forgot the end of that sentence ... "in one obscure corner case that's
already solved by sys_remap_file_pages."

I don't know of a problem with truncate, at least without the sorting code,
which seems to introduce i_shared_sem contention.

It also has some problems interacting with sys_remap_file_pages, which
people have already worked out how to fix, and Andrea posted a proposal for
yesterday.

>> From comments recently made on lkml I believe that the first problem is
>> probably 
> more pressing.  What problems need to be resolved with each patch?   

shpte still has some odd corner-case issues though it works fine for most
circumstances. I can update it for the latest kernel again, but there's not
much point until Dave has some more time to work on it.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
