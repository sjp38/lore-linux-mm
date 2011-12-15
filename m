Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 4D5396B01F8
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 01:49:07 -0500 (EST)
Message-ID: <4EE9983A.3060101@parallels.com>
Date: Thu, 15 Dec 2011 10:48:26 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v9 0/9] Request for inclusion: per-cgroup tcp memory pressure
 controls
References: <1323676029-5890-1-git-send-email-glommer@parallels.com> <20111215144019.03706ff7.kamezawa.hiroyu@jp.fujitsu.com> <20111215.004836.402973956281143052.davem@davemloft.net>
In-Reply-To: <20111215.004836.402973956281143052.davem@davemloft.net>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: kamezawa.hiroyu@jp.fujitsu.com, linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, ebiederm@xmission.com, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, avagin@parallels.com, devel@openvz.org, eric.dumazet@gmail.com, cgroups@vger.kernel.org

On 12/15/2011 09:48 AM, David Miller wrote:
> From: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
> Date: Thu, 15 Dec 2011 14:40:19 +0900
>
>> I met this bug at _1st_ run. Please enable _all_ debug options!.
>
> Plus the CONFIG_NET=n and other build failures.
>
> This patch series was seriously rushed, and very poorly handled.
>
> Yet I kept getting so much pressure to review, comment upon, and
> ultimately apply these patches.  Never, ever, do this to me ever
> again.
>
> If I don't feel your patches are high priority enough or ready enough
> for me to review, then TOO BAD.  Don't ask people to pressure me or
> get my attention.  Instead, ask others for help and do testing before
> wasting MY time and crapping up MY tree.
>
> I should have noticed a red flag when I have James Bottomly asking me
> to look at these patches, I should have pushed back.  Instead, I
> relented, and now I'm very seriously regretting it.
>
> All the regressions in the net-next tree over the past several days
> have been due to this patch set, and this patch set alone.
>
> This code wasn't ready and needed, at a minimum, several more weeks of
> work before being put in.
>
> Instead, we're going to bandaid patch it up after the fact, rather
> than just letting these changes mature naturally during the review
> process.
Hi Dave,

You are right about all points. I will admit to it, face it, and 
apologize it.
I guess the best I can do right now is fix whatever you guys point me to 
and not repeat it in the future.

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
