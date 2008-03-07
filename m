Message-Id: <47D0C326.6060103@mxp.nes.nec.co.jp>
Date: Fri, 07 Mar 2008 13:23:02 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Subject: Re: [RFC/PATCH] cgroup swap subsystem
References: <47CE36A9.3060204@mxp.nes.nec.co.jp> <47CE4BB6.8050803@linux.vnet.ibm.com>
In-Reply-To: <47CE4BB6.8050803@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: containers@lists.osdl.org, linux-mm@kvack.org, xemul@openvz.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Hi.

Balbir Singh wrote:
> Daisuke Nishimura wrote:
>> Basic idea of my implementation:
>>   - what will be charged ?
>>     the number of swap entries.
>>
>>   - when to charge/uncharge ?
>>     charge at get_swap_entry(), and uncharge at swap_entry_free().
>>
> 
> You mean get_swap_page(), I suppose. The assumption in the code is that every
> swap page being charged has already been charged by the memory controller (that
> will go against making the controllers independent). Also, be careful of any

To make swap-limit independent of memory subsystem, I think
page_cgroup code should be separated into two part:
subsystem-independent and subsystem-dependent, that is
part of associating page and page_cgroup and that of associating
page_cgroup and subsystem.

Rather than to do such a thing, I now think that
it would be better to implement swap-limit as part of
memory subsystem.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
