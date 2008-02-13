Message-ID: <47B32B27.4090406@openvz.org>
Date: Wed, 13 Feb 2008 20:38:47 +0300
From: Pavel Emelyanov <xemul@openvz.org>
MIME-Version: 1.0
Subject: Re: [RFC] [PATCH 1/4] Modify resource counters to add soft limit
 support
References: <20080213151201.7529.53642.sendpatchset@localhost.localdomain> <20080213151214.7529.3954.sendpatchset@localhost.localdomain> <47B324F4.1050102@openvz.org> <47B326BA.7040000@linux.vnet.ibm.com>
In-Reply-To: <47B326BA.7040000@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Nick Piggin <nickpiggin@yahoo.com.au>, "Eric W. Biederman" <ebiederm@xmission.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Rik Van Riel <riel@redhat.com>, Herbert Poetzl <herbert@13thfloor.at>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Balbir Singh wrote:
> Pavel Emelyanov wrote:
>> Balbir Singh wrote:
> 
>> Resource counter accounts for arbitrary resource. Memory pressure
>> and memory reclamation both only make sense in case we're dealing
>> with memory controller. Please, remove this comment or move it to
>> memcontrol.c.
>>
> 
> Yes, they always have. The concept of soft limits, hard limits, guarantees
> applies to all resources. Why do you say they apply only to memory controller? I

I said that *memory pressure and memory reclamation*, not the soft limits
in general, applies to memory controller only :)

> can change the comment to make the definition generic for all resources.
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
