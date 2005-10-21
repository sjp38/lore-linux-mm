Message-ID: <43591E6F.4020506@jp.fujitsu.com>
Date: Sat, 22 Oct 2005 01:59:27 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] Swap migration V3: sys_migrate_pages interface
References: <20051020225935.19761.57434.sendpatchset@schroedinger.engr.sgi.com> <20051020225955.19761.53060.sendpatchset@schroedinger.engr.sgi.com> <4358588D.1080307@jp.fujitsu.com> <Pine.LNX.4.61.0510210901380.17098@openx3.frec.bull.fr> <435896CA.1000101@jp.fujitsu.com> <Pine.LNX.4.62.0510210926120.23328@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0510210926120.23328@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Simon Derr <Simon.Derr@bull.net>, Andrew Morton <akpm@osdl.org>, Mike Kravetz <kravetz@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Magnus Damm <magnus.damm@gmail.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Paul Jackson <pj@sgi.com>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Fri, 21 Oct 2005, KAMEZAWA Hiroyuki wrote:
> 
> 
>>>>How about this ?
>>>>+cpuset_update_task_mems_allowed(task, new);    (this isn't implemented
>>>>now
>>
>>*new* is already guaranteed to be the subset of current mem_allowed.
>>Is this violate the permission ?
> 
>  
> Could the cpuset_mems_allowed(task) function update the mems_allowed if 
> needed?
It looks I was wrong :(
see Paul's e-mail. he describes the problem of my suggestion in detail.

-- Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
