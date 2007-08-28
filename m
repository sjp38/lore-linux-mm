Subject: Re: [-mm PATCH 5/10] Memory controller task migration (v7)
In-Reply-To: Your message of "Mon, 27 Aug 2007 16:09:15 +0530"
	<46D2A9D3.50703@linux.vnet.ibm.com>
References: <46D2A9D3.50703@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Message-Id: <20070828083252.C7D5C1BFA2F@siro.lan>
Date: Tue, 28 Aug 2007 17:32:52 +0900 (JST)
From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: akpm@linux-foundation.org, npiggin@suse.de, a.p.zijlstra@chello.nl, dhaval@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ebiederm@xmission.com, containers@lists.osdl.org, menage@google.com, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

> YAMAMOTO Takashi wrote:
> >> Allow tasks to migrate from one container to the other. We migrate
> >> mm_struct's mem_container only when the thread group id migrates.
> > 
> >> +	/*
> >> +	 * Only thread group leaders are allowed to migrate, the mm_struct is
> >> +	 * in effect owned by the leader
> >> +	 */
> >> +	if (p->tgid != p->pid)
> >> +		goto out;
> > 
> > does it mean that you can't move a process between containers
> > once its thread group leader exited?
> > 
> > YAMAMOTO Takashi
> 
> 
> Hi,
> 
> Good catch! Currently, we treat the mm as owned by the thread group leader.
> But this policy can be easily adapted to any other desired policy.
> Would you like to see it change to something else?
> 
> -- 
> 	Warm Regards,
> 	Balbir Singh
> 	Linux Technology Center
> 	IBM, ISTL

although i have no good idea right now, something which allows
to move a process with its thread group leader dead would be better.

YAMAMOTO Takashi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
