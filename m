Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id F29676B0087
	for <linux-mm@kvack.org>; Wed, 10 Feb 2010 23:15:52 -0500 (EST)
Message-ID: <4B73206C.8090108@redhat.com>
Date: Wed, 10 Feb 2010 16:09:00 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: Improving OOM killer
References: <201002012302.37380.l.lunak@suse.cz> <201002040858.33046.l.lunak@suse.cz> <alpine.DEB.2.00.1002041255080.6071@chino.kir.corp.google.com> <201002102154.39771.l.lunak@suse.cz>
In-Reply-To: <201002102154.39771.l.lunak@suse.cz>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Lubos Lunak <l.lunak@suse.cz>
Cc: David Rientjes <rientjes@google.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Jiri Kosina <jkosina@suse.cz>
List-ID: <linux-mm.kvack.org>

On 02/10/2010 03:54 PM, Lubos Lunak wrote:

>   Simply computing the cost of the whole children subtree (or a reasonable
> approximation) avoids the need for any magic numbers and gives a much better
> representation of how costly the subtree is, since, well, it is the cost
> itself.

That assumes you want to kill off that entire tree.

You will not want to do that when a web server or
database server runs out of memory, because the
goal of the OOM killer is to allow the system to
continue to run and be useful. This means keeping
the services available...

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
