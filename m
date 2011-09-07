Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 3E0246B016A
	for <linux-mm@kvack.org>; Tue,  6 Sep 2011 21:08:29 -0400 (EDT)
Received: by yie21 with SMTP id 21so110258yie.14
        for <linux-mm@kvack.org>; Tue, 06 Sep 2011 18:08:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1315276556-10970-1-git-send-email-glommer@parallels.com>
References: <1315276556-10970-1-git-send-email-glommer@parallels.com>
From: Paul Menage <paul@paulmenage.org>
Date: Tue, 6 Sep 2011 18:08:08 -0700
Message-ID: <CALdu-PDoPPdcX0bAkVpaP9R-z1yKin=JOjjT3rMuoSHJaywSCg@mail.gmail.com>
Subject: Re: [PATCH] per-cgroup tcp buffer limitation
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, netdev@vger.kernel.org, xemul@parallels.com, "David S. Miller" <davem@davemloft.net>, Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>, "Eric W. Biederman" <ebiederm@xmission.com>

On Mon, Sep 5, 2011 at 7:35 PM, Glauber Costa <glommer@parallels.com> wrote:
> This patch introduces per-cgroup tcp buffers limitation. This allows
> sysadmins to specify a maximum amount of kernel memory that
> tcp connections can use at any point in time. TCP is the main interest
> in this work, but extending it to other protocols would be easy.

The general idea of limiting total socket buffer memory consumed by a
cgroup is a fine idea, but I think it needs to be integrated more
closely with the existing kernel memory cgroup tracking efforts,
especially if you're trying to use as generic a name as "kmem" for it.

I agree with Kamezawa's comments that you need a lot more documentation.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
