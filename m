Message-ID: <4212C63D.2050606@sgi.com>
Date: Tue, 15 Feb 2005 22:04:13 -0600
From: Ray Bryant <raybry@sgi.com>
MIME-Version: 1.0
Subject: Re: manual page migration -- issue list
References: <42128B25.9030206@sgi.com> <20050215165106.61fd4954.pj@sgi.com> <20050215171709.64b155ec.pj@sgi.com> <20050216020138.GC28354@lnx-holt.americas.sgi.com>
In-Reply-To: <20050216020138.GC28354@lnx-holt.americas.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, ak@muc.de, haveblue@us.ibm.com, marcello@cyclades.com, stevel@mwwireless.net, peterc@gelato.unsw.edu.au
List-ID: <linux-mm.kvack.org>

Robin Holt wrote:
> On Tue, Feb 15, 2005 at 05:17:09PM -0800, Paul Jackson wrote:
> 
>>As a straw man, let me push the factored migration call to the
>>extreme, and propose a call:
>>
>>  sys_page_migrate(pid, oldnode, newnode)
> 
> 
> Go look at the mappings in /proc/<pid>/maps once and you will see
> how painful this can make things.  Especially for an applications
> with shared mappings.  Overlapping nodes with the above will make
> a complete mess of your memory placement.
> 
> Robin
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
> 
So lets address that issue again, since I think that is now the
heart of the matter.

Exactly why do we need to support the case where the set of old
nodes and new nodes overlap?  I agree it is more general, but if
we drop that, I think we are one step closer to getting agreement
as to what the page migration system call interface should be.

Do we have a case, say from IRIX, of why supporting this kind of
migration is necessary?

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
