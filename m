Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 873C88D0048
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 17:52:13 -0500 (EST)
Message-ID: <4D643E1B.7050507@linux.intel.com>
Date: Tue, 22 Feb 2011 14:52:11 -0800
From: Andi Kleen <ak@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 6/8] Add __GFP_OTHER_NODE flag
References: <1298315270-10434-1-git-send-email-andi@firstfloor.org> <1298315270-10434-7-git-send-email-andi@firstfloor.org> <alpine.DEB.2.00.1102221333100.5929@chino.kir.corp.google.com> <4D642F03.5040800@linux.intel.com> <alpine.DEB.2.00.1102221402150.5929@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1102221402150.5929@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, lwoodman@redhat.com


> You could make the same argument for anything using kmalloc_node() since
> preferred_zone may very well not be on the allocating cpu's node.

You're right. It is not always, that is why I defined a new flag. In the 
cases where the flag
is passed it is.



>   So you
> either define NUMA_LOCAL to account for when a cpu allocates memory local
> to itself (as it's name implies) or you define it to account for when
> memory comes from the preferred_zone's node as determined by the zonelist.

That's already numa_hit as you say.

I just don't think "local to some random kernel daemon that means 
nothing to the user"
is a useful definition for local_hit.

When I defined the counter I intended it to be local to the user 
process. It always was like
that too, just THP changed the rules.

-Andi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
