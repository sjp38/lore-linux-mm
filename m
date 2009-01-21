Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6D8336B0044
	for <linux-mm@kvack.org>; Wed, 21 Jan 2009 04:36:40 -0500 (EST)
Received: from zps75.corp.google.com (zps75.corp.google.com [172.25.146.75])
	by smtp-out.google.com with ESMTP id n0L9aarZ003760
	for <linux-mm@kvack.org>; Wed, 21 Jan 2009 09:36:37 GMT
Received: from rv-out-0506.google.com (rvfb25.prod.google.com [10.140.179.25])
	by zps75.corp.google.com with ESMTP id n0L9aXwx006998
	for <linux-mm@kvack.org>; Wed, 21 Jan 2009 01:36:33 -0800
Received: by rv-out-0506.google.com with SMTP id b25so3781828rvf.41
        for <linux-mm@kvack.org>; Wed, 21 Jan 2009 01:36:33 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20090120144337.82ed51d5.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090115192120.9956911b.kamezawa.hiroyu@jp.fujitsu.com>
	 <20090115192712.33b533c3.kamezawa.hiroyu@jp.fujitsu.com>
	 <6599ad830901191739t45c793afk2ceda8fc430121ce@mail.gmail.com>
	 <20090120110221.005e116c.kamezawa.hiroyu@jp.fujitsu.com>
	 <6599ad830901191823q556faeeub28d02d39dda7396@mail.gmail.com>
	 <20090120115832.0881506c.kamezawa.hiroyu@jp.fujitsu.com>
	 <20090120144337.82ed51d5.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 21 Jan 2009 01:36:32 -0800
Message-ID: <6599ad830901210136j9baf45ft4c86a93fec70827f@mail.gmail.com>
Subject: Re: [PATCH 1.5/4] cgroup: delay populate css id
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 19, 2009 at 9:43 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> +static void populate_css_id(struct cgroup_subsys_state *css)
> +{
> +       struct css_id *id = rcu_dereference(css->id);
> +       if (id)
> +               rcu_assign_pointer(id->css, css);
> +}

I don't think this needs to be split out into a separate function.
Also, there's no need for an rcu_dereference(), since we're holding
cgroup_mutex.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
