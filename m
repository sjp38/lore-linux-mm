Message-ID: <489314FE.7080900@linux-foundation.org>
Date: Fri, 01 Aug 2008 08:51:58 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [RFC:Patch: 000/008](memory hotplug) rough idea of pgdat removing
References: <20080731203549.2A3F.E1E9C6FF@jp.fujitsu.com> <4891C66A.3040302@linux-foundation.org> <20080801180522.EC97.E1E9C6FF@jp.fujitsu.com>
In-Reply-To: <20080801180522.EC97.E1E9C6FF@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Badari Pulavarty <pbadari@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm <linux-mm@kvack.org>, Linux Kernel ML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Yasunori Goto wrote:

> I thought it at first, but are there the following worst case?
> 
> 
>    CPU 0                                    CPU 1
> -------------------------------------------------------
> __alloc_pages()
>     
>     parsing_zonelist()
>         :
>     enter page_reclarim()
>     sleep (and remember zone)                 :
>                                               :
>                                         update zonelist and node_online_map
>                                           with stop_machine_run()
>                                         free pgdat().
>                                         remove the Node electrically.
> 
>     wake up and touch remembered
>        zone,  but it is removed
>     (Oops!!!)
> 
> 
> 
> Anyway, I'm happy if there is better way than my poor idea. :-)
> 
> Thanks for your comment.

Duh. Then the use of RCU would also mean that all of reclaim must be in a rcu period. So  reclaim cannot sleep anymore.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
