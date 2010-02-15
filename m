Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 298E56B007B
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 06:17:02 -0500 (EST)
Received: by ewy22 with SMTP id 22so461595ewy.10
        for <linux-mm@kvack.org>; Mon, 15 Feb 2010 03:17:00 -0800 (PST)
Subject: Re: 2.6.31 and OOM killer = bug?
Mime-Version: 1.0 (Apple Message framework v1077)
Content-Type: text/plain; charset=us-ascii
From: Anton Starikov <ant.starikov@gmail.com>
In-Reply-To: <20100215101917.15552a51.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 15 Feb 2010 12:16:57 +0100
Content-Transfer-Encoding: quoted-printable
Message-Id: <548A11C6-8C8C-45EF-92E7-72C3DF47F9FD@gmail.com>
References: <E0975165-4185-47A9-A15F-B46774A5F6DA@gmail.com> <20100215101917.15552a51.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


On Feb 15, 2010, at 2:19 AM, KAMEZAWA Hiroyuki wrote:
> At first, what is the version of kernel you are comparing with ? =
2.6.22?(If OpenSuse10)
> If so, many changes since that..


Latest kernel version where OOM killer worked as it should in our setup =
was 2.6.29.

> Anyway, I think it's not appreciated to depend on OOM-Kill on =
swapless-system.
> I recommend you to use cgroup "memory" to encapsulate your apps (but =
please check
> the performance regression can be seen or not..)

OK, I will check it.

Thanks,=20
Anton.=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
