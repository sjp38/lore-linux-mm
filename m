MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <16914.28795.316835.291470@wombat.chubb.wattle.id.au>
Date: Wed, 16 Feb 2005 08:58:19 +1100
From: Peter Chubb <peterc@gelato.unsw.edu.au>
Subject: Re: [RFC 2.6.11-rc2-mm2 7/7] mm: manual page migration -- sys_page_migrate
In-Reply-To: <20050215185943.GA24401@lnx-holt.americas.sgi.com>
References: <20050212032535.18524.12046.26397@tomahawk.engr.sgi.com>
	<20050212032620.18524.15178.29731@tomahawk.engr.sgi.com>
	<1108242262.6154.39.camel@localhost>
	<20050214135221.GA20511@lnx-holt.americas.sgi.com>
	<1108407043.6154.49.camel@localhost>
	<20050214220148.GA11832@lnx-holt.americas.sgi.com>
	<20050215074906.01439d4e.pj@sgi.com>
	<20050215162135.GA22646@lnx-holt.americas.sgi.com>
	<20050215083529.2f80c294.pj@sgi.com>
	<20050215185943.GA24401@lnx-holt.americas.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Paul Jackson <pj@sgi.com>, haveblue@us.ibm.com, raybry@sgi.com, taka@valinux.co.jp, hugh@veritas.com, akpm@osdl.org, marcello@cyclades.com, raybry@austin.rr.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

>>>>> "Robin" == Robin Holt <holt@sgi.com> writes:

Robin> On Tue, Feb 15, 2005 at 08:35:29AM -0800, Paul Jackson wrote:
>> What about the suggestion I had that you sort of skipped over,
>> which amounted to changing the system call from a node array to
>> just one node:
>> 
>> sys_page_migrate(pid, va_start, va_end, count, old_nodes,
>> new_nodes);
>> 
>> to:
>> 
>> sys_page_migrate(pid, va_start, va_end, old_node, new_node);
>> 
>> Doesn't that let you do all you need to?  Is it insane too?

Robin> Migration could be done in most cases and would only fall apart
Robin> when there are overlapping node lists and no nodes available as
Robin> temp space and we are not moving large chunks of data.

A possibly stupid suggestion: 

Can page migration be done lazily, instead of all at once?  Move the
process, mark its pages as candidates for migration, and when 
the page faults, decide whether to copy across or not...

That way you only copy the pages the process is using, and only copy
each page once.  It makes copy for replication easier in some future
incarnation, too, because the same basic infrastructure can be used.

--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
