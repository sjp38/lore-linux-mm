Subject: Re: [PATCH][RFC] dirty balancing for cgroups
In-Reply-To: Your message of "Mon, 14 Jul 2008 15:49:04 +0200"
	<1216043344.12595.89.camel@twins>
References: <1216043344.12595.89.camel@twins>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Message-Id: <20080717014335.ED78A5A22@siro.lan>
Date: Thu, 17 Jul 2008 10:43:35 +0900 (JST)
From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: a.p.zijlstra@chello.nl
Cc: kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, menage@google.com, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

hi,

> Now the problem this patch tries to address...
> 
> As you can see you'd need p_{bdi,cgroup,task} for it to work, and the
> obvious approximation p_bdi * p_cgroup * p_task will get even more
> coarse.
> 
> You could possibly attempt to do p_{bdi,cgroup} * p_task since the bdi
> and cgroup set are pretty static, but still that would be painful.

i chose min(p_bdi * p_cgroup, p_bdi * p_task) because i couldn't imagine
a case where p_bdi * p_cgroup * p_task is better.

> So, could you please give some more justification for this work, I'm not
> seeing the value in complicating all this just yet.

a simple example for which my patch can make some sense is:

	while :;do dd if=/dev/zero of=file conv=notrunc bs=4096 count=1;done

YAMAMOTO Takashi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
