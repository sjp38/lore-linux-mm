Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id EA82A6B0071
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 19:18:20 -0500 (EST)
Message-ID: <4B6A1241.60009@redhat.com>
Date: Wed, 03 Feb 2010 19:18:09 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: Improving OOM killer
References: <201002012302.37380.l.lunak@suse.cz> <20100203170127.GH19641@balbir.in.ibm.com> <alpine.DEB.2.00.1002031021190.14088@chino.kir.corp.google.com> <201002032355.01260.l.lunak@suse.cz> <alpine.DEB.2.00.1002031600490.27918@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1002031600490.27918@chino.kir.corp.google.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Lubos Lunak <l.lunak@suse.cz>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Jiri Kosina <jkosina@suse.cz>
List-ID: <linux-mm.kvack.org>

On 02/03/2010 07:05 PM, David Rientjes wrote:
> On Wed, 3 Feb 2010, Lubos Lunak wrote:

>>> 		/* Forkbombs get penalized 10% of available RAM */
>>> 		if (forkcount>  500)
>>> 			points += 100;

> Do you have any comments about the forkbomb detector or its threshold that
> I've put in my heuristic?  I think detecting these scenarios is still an
> important issue that we need to address instead of simply removing it from
> consideration entirely.

I believe that malicious users are best addressed in person,
or preemptively through cgroups and rlimits.

Having a process with over 500 children is quite possible
with things like apache, Oracle, postgres and other forking
daemons.

Killing the parent process can result in the service
becoming unavailable, and in some cases even data
corruption.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
