Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 36EED6B016A
	for <linux-mm@kvack.org>; Tue,  6 Sep 2011 21:30:17 -0400 (EDT)
Received: by ywm13 with SMTP id 13so5295545ywm.14
        for <linux-mm@kvack.org>; Tue, 06 Sep 2011 18:30:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4E66C45A.8060706@parallels.com>
References: <1315276556-10970-1-git-send-email-glommer@parallels.com>
 <CALdu-PDoPPdcX0bAkVpaP9R-z1yKin=JOjjT3rMuoSHJaywSCg@mail.gmail.com> <4E66C45A.8060706@parallels.com>
From: Paul Menage <paul@paulmenage.org>
Date: Tue, 6 Sep 2011 18:29:55 -0700
Message-ID: <CALdu-PDZC3FTuR31d5+P+=U=0UFVUZD_KDEgPHBeD-MyQ4PuSQ@mail.gmail.com>
Subject: Re: [PATCH] per-cgroup tcp buffer limitation
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, netdev@vger.kernel.org, xemul@parallels.com, "David S. Miller" <davem@davemloft.net>, Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>, "Eric W. Biederman" <ebiederm@xmission.com>

On Tue, Sep 6, 2011 at 6:09 PM, Glauber Costa <glommer@parallels.com> wrote:
>
> Can you be more specific?

Maybe if you include the source to kmem_cgroup.c :-)

Things like the reporting of stats to user space, configuring limits,
etc, ought to be common with the other kernel memory tracking. (Sadly,
I've lost track of the status of the other kernel memory effort -
Kamezawa or the OpenVZ folks probably have a better handle on that).

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
