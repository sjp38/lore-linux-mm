Date: Wed, 06 Oct 2004 08:14:08 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [RFC/PATCH]  pfn_valid() more generic : arch independent part[0/2]
Message-ID: <1209350000.1097075647@[10.10.2.4]>
In-Reply-To: <416392BF.1020708@jp.fujitsu.com>
References: <416392BF.1020708@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>, LinuxIA64 <linux-ia64@vger.kernel.org>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> This is generic parts.
> 
> Boot-time routine:
> At first, information of valid pages is gathered into a list.
> After gathering all information, 2 level table are created.
> Why I create table instead of using a list is only for good cache hit.
> 
> pfn_valid_init()  <- initilize some structures
> validate_pages(start,size) <- gather valid pfn information
> pfn_valid_setup() <- create 1st and 2nd table.


Boggle. what on earth are you trying to do?

pfn_valid does exactly one thing - it checks whether there is a struct
page for that pfn. Nothing else. Surely that can't possibly take a tenth
of this amount of code?

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
