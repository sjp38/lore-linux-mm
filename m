Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 6BE726B016B
	for <linux-mm@kvack.org>; Tue,  6 Sep 2011 21:10:36 -0400 (EDT)
Message-ID: <4E66C45A.8060706@parallels.com>
Date: Tue, 6 Sep 2011 22:09:46 -0300
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] per-cgroup tcp buffer limitation
References: <1315276556-10970-1-git-send-email-glommer@parallels.com> <CALdu-PDoPPdcX0bAkVpaP9R-z1yKin=JOjjT3rMuoSHJaywSCg@mail.gmail.com>
In-Reply-To: <CALdu-PDoPPdcX0bAkVpaP9R-z1yKin=JOjjT3rMuoSHJaywSCg@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Menage <paul@paulmenage.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, netdev@vger.kernel.org, xemul@parallels.com, "David S. Miller" <davem@davemloft.net>, Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>, "Eric W. Biederman" <ebiederm@xmission.com>

On 09/06/2011 10:08 PM, Paul Menage wrote:
> On Mon, Sep 5, 2011 at 7:35 PM, Glauber Costa<glommer@parallels.com>  wrote:
>> This patch introduces per-cgroup tcp buffers limitation. This allows
>> sysadmins to specify a maximum amount of kernel memory that
>> tcp connections can use at any point in time. TCP is the main interest
>> in this work, but extending it to other protocols would be easy.

Hi Paul,


> The general idea of limiting total socket buffer memory consumed by a
> cgroup is a fine idea, but I think it needs to be integrated more
> closely with the existing kernel memory cgroup tracking efforts,
> especially if you're trying to use as generic a name as "kmem" for it.
Can you be more specific?

The generic part of kmem cgroup in this patch is quite simple. I think 
any other patchset would have a very easy time merging things into it.
90 % is sockets.

>
> I agree with Kamezawa's comments that you need a lot more documentation.
Working on it right now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
