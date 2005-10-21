Message-ID: <435896CA.1000101@jp.fujitsu.com>
Date: Fri, 21 Oct 2005 16:20:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] Swap migration V3: sys_migrate_pages interface
References: <20051020225935.19761.57434.sendpatchset@schroedinger.engr.sgi.com> <20051020225955.19761.53060.sendpatchset@schroedinger.engr.sgi.com> <4358588D.1080307@jp.fujitsu.com> <Pine.LNX.4.61.0510210901380.17098@openx3.frec.bull.fr>
In-Reply-To: <Pine.LNX.4.61.0510210901380.17098@openx3.frec.bull.fr>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Simon Derr <Simon.Derr@bull.net>
Cc: Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@osdl.org>, Mike Kravetz <kravetz@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Magnus Damm <magnus.damm@gmail.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Paul Jackson <pj@sgi.com>
List-ID: <linux-mm.kvack.org>


> Christoph Lameter wrote:
> 
>>> > +	/* Is the user allowed to access the target nodes? */
>>> > +	if (!nodes_subset(new, cpuset_mems_allowed(task)))
>>> > +		return -EPERM;
>>> > +
> 
>> How about this ?
>> +cpuset_update_task_mems_allowed(task, new);    (this isn't implemented now

*new* is already guaranteed to be the subset of current mem_allowed.
Is this violate the permission ?

Simon Derr wrote:
> Automatically updating the ->mems_allowed field as you suggest would 
> require that the kernel do the same checks in sys_migrage_pages(). Sounds 
> not as a very good idea to me.

Hmm, it means a user or admin should modify mem_allowed
before the first page fault after calling sys_migrate_pages().

-- Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
