Message-ID: <4212C429.4080508@sgi.com>
Date: Tue, 15 Feb 2005 21:55:21 -0600
From: Ray Bryant <raybry@sgi.com>
MIME-Version: 1.0
Subject: Re: manual page migration -- issue list
References: <42128B25.9030206@sgi.com>	<20050215165106.61fd4954.pj@sgi.com> <20050215171709.64b155ec.pj@sgi.com>
In-Reply-To: <20050215171709.64b155ec.pj@sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: linux-mm@kvack.org, holt@sgi.com, ak@muc.de, haveblue@us.ibm.com, marcello@cyclades.com, stevel@mwwireless.net, peterc@gelato.unsw.edu.au
List-ID: <linux-mm.kvack.org>

Paul Jackson wrote:
> As a straw man, let me push the factored migration call to the
> extreme, and propose a call:
> 
>   sys_page_migrate(pid, oldnode, newnode)
> 
> that moves any physical page in the address space of pid that is
> currently located on oldnode to newnode.
> 
> Won't this come about as close as we are going to get to replicating the
> physical memory layout of a job, if we just call it once, for each task
> in that job?  Oops - make that one call for each node in use by the job
> - see the following ...
> 
> 
> Earlier I (pj) wrote:
> 
>>The one thing not trivially covered in such a one task, one node pair at
>>a time factoring is memory that is placed on a node that is remote from
>>any of the tasks which map that memory.  Let me call this 'remote
>>placement.'  Offhand, I don't know why anyone would do this.
> 
> 
> Well - one case - headless nodes.  These are memory-only nodes.
> 
> Typically one sys_page_migrate() call will be needed for each such node,
> specifying some task in the job that has all the relevent memory on that
> node mapped, specifying that (old) node, and specifying which new node
> that memory should be migrated to.
> 

This works provide you get Robin and Jack and all to drop the requirement
that my page migration facility support overlapping sets of origin and
destination nodes.  Otherwise, this is a non-starter.

So, lets go back to that one.  Robin, can you provide me with a concrete
(not hypothetical example) of a case where the from and to sets of nodes
are overlapping?

-- 
-----------------------------------------------
Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
	 so I installed Linux.
-----------------------------------------------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
