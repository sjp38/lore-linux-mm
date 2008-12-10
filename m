From: Paul Menage <menage@google.com>
Subject: Re: [RFC][PATCH 1/6] memcg: fix pre_destory handler
Date: Wed, 10 Dec 2008 10:25:20 -0800
Message-ID: <6599ad830812101025s4a8eab08v214ccc95565c398e@mail.gmail.com>
References: <6599ad830812100240g5e549a5cqe29cbea736788865@mail.gmail.com>
	 <29741.10.75.179.61.1228908581.squirrel@webmail-b.css.fujitsu.com>
	 <20081210132559.GF25467@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <owner-linux-mm@kvack.org>
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id mBAIPQeH014241
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 10:25:26 -0800
Received: from qw-out-1920.google.com (qwk4.prod.google.com [10.241.195.132])
	by wpaz9.hot.corp.google.com with ESMTP id mBAIPK4A016666
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 10:25:20 -0800
Received: by qw-out-1920.google.com with SMTP id 4so172869qwk.24
        for <linux-mm@kvack.org>; Wed, 10 Dec 2008 10:25:20 -0800 (PST)
In-Reply-To: <20081210132559.GF25467@balbir.in.ibm.com>
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Paul Menage <menage@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, nishimura@mxp.nes.nec.co.j
List-Id: linux-mm.kvack.org

On Wed, Dec 10, 2008 at 5:25 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>
> Paul, I can't find those patches in -mm. I will try and dig them out
> from my mbox. I agree, we need a hierarchy_mutex, cgroup_mutex is
> becoming the next BKL.

It never actually went into -mm. I'll sync it with the latest tree and
try to send it out today.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
