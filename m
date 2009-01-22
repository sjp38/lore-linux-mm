Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2157D6B0089
	for <linux-mm@kvack.org>; Wed, 21 Jan 2009 21:14:00 -0500 (EST)
Received: from spaceape9.eur.corp.google.com (spaceape9.eur.corp.google.com [172.28.16.143])
	by smtp-out.google.com with ESMTP id n0M2Dv0h016043
	for <linux-mm@kvack.org>; Wed, 21 Jan 2009 18:13:58 -0800
Received: from rv-out-0506.google.com (rvbf6.prod.google.com [10.140.82.6])
	by spaceape9.eur.corp.google.com with ESMTP id n0M2DPhv005919
	for <linux-mm@kvack.org>; Wed, 21 Jan 2009 18:13:53 -0800
Received: by rv-out-0506.google.com with SMTP id f6so4150957rvb.55
        for <linux-mm@kvack.org>; Wed, 21 Jan 2009 18:13:53 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20090122110632.e5c4216c.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090115192120.9956911b.kamezawa.hiroyu@jp.fujitsu.com>
	 <20090115192712.33b533c3.kamezawa.hiroyu@jp.fujitsu.com>
	 <6599ad830901191739t45c793afk2ceda8fc430121ce@mail.gmail.com>
	 <20090120110221.005e116c.kamezawa.hiroyu@jp.fujitsu.com>
	 <6599ad830901191823q556faeeub28d02d39dda7396@mail.gmail.com>
	 <20090120115832.0881506c.kamezawa.hiroyu@jp.fujitsu.com>
	 <20090120144337.82ed51d5.kamezawa.hiroyu@jp.fujitsu.com>
	 <6599ad830901210136j9baf45ft4c86a93fec70827f@mail.gmail.com>
	 <20090121193436.c314ad7d.kamezawa.hiroyu@jp.fujitsu.com>
	 <20090122110632.e5c4216c.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 21 Jan 2009 18:13:53 -0800
Message-ID: <6599ad830901211813v1256db8q36facac4f99f4837@mail.gmail.com>
Subject: Re: [PATCH 1.5/4] cgroup: delay populate css id
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 21, 2009 at 6:06 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
> BTW, isn't it better to use rcu_assign_pointer to show "this pointer will be
> dereferenced from RCU-read-side" ?
>

Yes, I think using rcu_assign_pointer() is fine here.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
