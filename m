Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id A9CE86B0047
	for <linux-mm@kvack.org>; Thu,  4 Feb 2010 17:07:06 -0500 (EST)
Message-ID: <4B6B4500.3010603@redhat.com>
Date: Thu, 04 Feb 2010 17:06:56 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: Improving OOM killer
References: <201002012302.37380.l.lunak@suse.cz> <20100203170127.GH19641@balbir.in.ibm.com> <alpine.DEB.2.00.1002031021190.14088@chino.kir.corp.google.com> <201002032355.01260.l.lunak@suse.cz> <alpine.DEB.2.00.1002031600490.27918@chino.kir.corp.google.com> <4B6A1241.60009@redhat.com> <alpine.DEB.2.00.1002041339220.6071@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1002041339220.6071@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Lubos Lunak <l.lunak@suse.cz>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Jiri Kosina <jkosina@suse.cz>
List-ID: <linux-mm.kvack.org>

On 02/04/2010 04:48 PM, David Rientjes wrote:

> Keep in mind that we're in the oom killer here, though.  So we're out of
> memory and we need to kill something; should Apache, Oracle, and postgres
> not be penalized for their cost of running by factoring in something like
> this?

No, they should not.

The goal of the OOM killer is to kill some process, so the
system can continue running and automatically become available
again for whatever workload the system was running.

Killing the parent process of one of the system daemons does
not achieve that goal, because you now caused a service to no
longer be available.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
