Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D24A46B0039
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 16:06:40 -0400 (EDT)
Message-ID: <4E9744A6.5010101@parallels.com>
Date: Fri, 14 Oct 2011 00:05:58 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v7 0/8] Request for inclusion: tcp memory buffers
References: <1318511382-31051-1-git-send-email-glommer@parallels.com> <20111013.160031.605700447623532119.davem@davemloft.net>
In-Reply-To: <20111013.160031.605700447623532119.davem@davemloft.net>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, paul@paulmenage.org, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, avagin@parallels.com, devel@openvz.org

On 10/14/2011 12:00 AM, David Miller wrote:
> From: Glauber Costa<glommer@parallels.com>
> Date: Thu, 13 Oct 2011 17:09:34 +0400
>
>> This series was extensively reviewed over the past month, and after
>> all major comments were merged, I feel it is ready for inclusion when
>> the next merge window opens. Minor fixes will be provided if they
>> prove to be necessary.
>
> I'm not applying this.

Thank you for letting me now about your view of this that early.

> You're turning inline increments and decrements of the existing memory
> limits into indirect function calls.

Yes, indeed.

> That imposes a new non-trivial cost, in fast paths, even when people
> do not use your feature.
Well, there is a cost, but all past submissions included round trip 
benchmarks.
In none of them I could see any significant slowdown.

> Make this evaluate into exactly the same exact code stream we have
> now when the memory cgroup feature is not in use, which will be the
> majority of users.

What exactly do you mean by "not in use" ? Not compiled in or not 
actively being exercised ? If you mean the later, I appreciate tips on 
how to achieve it.

Also, I kind of dispute the affirmation that !cgroup will encompass
the majority of users, since cgroups is being enabled by default by
most vendors. All systemd based systems use it extensively, for instance.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
