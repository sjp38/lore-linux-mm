Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 2F9246B004D
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 09:19:46 -0400 (EDT)
Received: by dakp5 with SMTP id p5so8630289dak.14
        for <linux-mm@kvack.org>; Mon, 18 Jun 2012 06:19:45 -0700 (PDT)
Date: Mon, 18 Jun 2012 21:19:32 +0800
From: Wanpeng Li <liwp.linux@gmail.com>
Subject: Re: [PATCH] mm/memcg: add unlikely to mercg->move_charge_at_immigrate
Message-ID: <20120618131918.GA2600@kernel>
Reply-To: Wanpeng Li <liwp.linux@gmail.com>
References: <1340025022-7272-1-git-send-email-liwp.linux@gmail.com>
 <4FDF2890.3020004@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FDF2890.3020004@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Gavin Shan <shangw@linux.vnet.ibm.com>, Wanpeng Li <liwp.linux@gmail.com>

On Mon, Jun 18, 2012 at 05:09:36PM +0400, Glauber Costa wrote:
>On 06/18/2012 05:10 PM, Wanpeng Li wrote:
>>From: Wanpeng Li <liwp@linux.vnet.ibm.com>
>>
>>move_charge_at_immigrate feature is disabled by default. Charges
>>are moved only when you move mm->owner and it also add additional
>>overhead.
>
>How big is this overhead?
>
>That's hardly a fast path. And if it happens to matter, it will be
>just bigger when you enable it, and the compiler start giving the
>wrong hints to the code.

Thank you for your quick response.

Oh, Maybe I should just write comments "move_charge_at_immigrate feature
is disabled by default. So add "unlikely", in order to compiler can optimize."

Best Regards,
Wanpeng Li

>--
>To unsubscribe from this list: send the line "unsubscribe cgroups" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
