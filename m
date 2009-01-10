Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id B8F706B009C
	for <linux-mm@kvack.org>; Fri,  9 Jan 2009 19:49:32 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0A0nT8q003318
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Sat, 10 Jan 2009 09:49:29 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 791B245DD74
	for <linux-mm@kvack.org>; Sat, 10 Jan 2009 09:49:30 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4EC5345DD72
	for <linux-mm@kvack.org>; Sat, 10 Jan 2009 09:49:30 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C34C21DB803C
	for <linux-mm@kvack.org>; Sat, 10 Jan 2009 09:49:28 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 817DF1DB803A
	for <linux-mm@kvack.org>; Sat, 10 Jan 2009 09:49:28 +0900 (JST)
Message-ID: <8c182b969c7f3c9c583b879709767ed7.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <6599ad830901091623i2c3f6ce1ma88c845074b7c013@mail.gmail.com>
References: <20090108182556.621e3ee6.kamezawa.hiroyu@jp.fujitsu.com>
    <20090108182817.2c393351.kamezawa.hiroyu@jp.fujitsu.com>
    <6599ad830901091623i2c3f6ce1ma88c845074b7c013@mail.gmail.com>
Date: Sat, 10 Jan 2009 09:49:28 +0900 (JST)
Subject: Re: [RFC][PATCH 1/4] cgroup: support per cgroup subsys state ID
 (CSS  ID)
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Paul Menage <menage@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Paul Menage さんは書きました：
> On Thu, Jan 8, 2009 at 1:28 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> + *
>> + * Looking up and scanning function should be called under
>> rcu_read_lock().
>> + * Taking cgroup_mutex()/hierarchy_mutex() is not necessary for all
>> calls.
>
> Can you clarify here - do you mean "not necessary for any calls"
> (calls to what?) or "not necessary for some calls"? I presume the
> former.
>
Ah, sorry bad text.

not necessary for any calls related to css_id.

-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
