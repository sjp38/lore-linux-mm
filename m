Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 709686B0011
	for <linux-mm@kvack.org>; Wed,  1 Jun 2011 09:49:40 -0400 (EDT)
Message-ID: <4DE6436B.3080002@redhat.com>
Date: Wed, 01 Jun 2011 15:49:31 +0200
From: Igor Mammedov <imammedo@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: do not expose uninitialized mem_cgroup_per_node
 to world
References: <1306925044-2828-1-git-send-email-imammedo@redhat.com> <20110601123913.GC4266@tiehlicka.suse.cz>
In-Reply-To: <20110601123913.GC4266@tiehlicka.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, balbir@linux.vnet.ibm.com, akpm@linux-foundation.org, linux-mm@kvack.org

On 06/01/2011 02:39 PM, Michal Hocko wrote:
> I am not saying tha the change is bad, I like it, but I do not think it
> is a fix for potential race condition.
And yes, I agree that it is rather a workaround than real fix of race
condition which shouldn't exist in the first place. But giving my very
limited knowledge of cgroups and difficulty to reproduce the crash
after adding/enabling additional debugging, that patch is what
can fix the problem for now.
And maybe more experienced guys will look at the code and fix it
in the right way. Well at least I hope for that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
