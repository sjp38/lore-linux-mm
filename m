Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 6D6CB900172
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 14:12:07 -0400 (EDT)
Message-ID: <4E6F9CC4.2000601@parallels.com>
Date: Tue, 13 Sep 2011 15:11:16 -0300
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] per-cgroup tcp buffer limitation
References: <1315276556-10970-1-git-send-email-glommer@parallels.com> <CAHH2K0aJxjinSu0Ek6jzsZ5dBmm5mEU-typuwYWYWEudF2F3Qg@mail.gmail.com> <4E664766.40200@parallels.com> <CAHH2K0YJA7vZZ3QNAf63TZOnWhsRUwfuZYfntBL4muZ0G_Vt2w@mail.gmail.com> <4E66A0A9.3060403@parallels.com> <CAHH2K0aq4s1_H-yY0kA3LhM00CCNNbJZyvyBoDD6rHC+qo_gNg@mail.gmail.com> <4E68484A.4000201@parallels.com> <CAHH2K0YcXMUfd1Zr=f5a4=X9cPPp8NZiuichFXaOo=kVp5rRJA@mail.gmail.com> <4E699341.9010606@parallels.com> <CALdu-PCrYPZx38o44ZyFrbQ6H39-vNPKey_Tpm4HRUNHNFMpyA@mail.gmail.com> <4E6E39DD.2040102@parallels.com> <CALdu-PC7ESSUHuF4vfVoRFFfkaBt1V28rGW3-O5pT3WtegAh4g@mail.gmail.com>
In-Reply-To: <CALdu-PC7ESSUHuF4vfVoRFFfkaBt1V28rGW3-O5pT3WtegAh4g@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Menage <paul@paulmenage.org>
Cc: Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, netdev@vger.kernel.org, xemul@parallels.com, "David S. Miller" <davem@davemloft.net>, Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Suleiman Souhlal <suleiman@google.com>, Lennart Poettering <lennart@poettering.net>

On 09/13/2011 03:09 PM, Paul Menage wrote:
> Each set of counters (user, kernel, total) will have its own locks,
> contention and other overheads to keep up to date. If userspace
> doesn't care about one or two of the three, then that's mostly wasted.
>
> Now it might be that the accounting of all three can be done with
> little more overhead than that required to update just a split view or
> just a unified view, in which case there's much less argument against
> simplifying and tracking/charging/limiting all three.
What if they are all updated under the same lock ?
The lock argument is very well valid for accounting vs not accounting 
kernel memory. But once it is accounted, which counter we account to, I 
think, is less of a problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
