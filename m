Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 77A086B0093
	for <linux-mm@kvack.org>; Fri,  9 Jan 2009 19:24:00 -0500 (EST)
Received: from spaceape14.eur.corp.google.com (spaceape14.eur.corp.google.com [172.28.16.148])
	by smtp-out.google.com with ESMTP id n0A0Nu39022293
	for <linux-mm@kvack.org>; Sat, 10 Jan 2009 00:23:56 GMT
Received: from rv-out-0506.google.com (rvbf6.prod.google.com [10.140.82.6])
	by spaceape14.eur.corp.google.com with ESMTP id n0A0N5hU006302
	for <linux-mm@kvack.org>; Fri, 9 Jan 2009 16:23:54 -0800
Received: by rv-out-0506.google.com with SMTP id f6so13652376rvb.5
        for <linux-mm@kvack.org>; Fri, 09 Jan 2009 16:23:53 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20090108182817.2c393351.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090108182556.621e3ee6.kamezawa.hiroyu@jp.fujitsu.com>
	 <20090108182817.2c393351.kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 9 Jan 2009 16:23:53 -0800
Message-ID: <6599ad830901091623i2c3f6ce1ma88c845074b7c013@mail.gmail.com>
Subject: Re: [RFC][PATCH 1/4] cgroup: support per cgroup subsys state ID (CSS
	ID)
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 8, 2009 at 1:28 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> + *
> + * Looking up and scanning function should be called under rcu_read_lock().
> + * Taking cgroup_mutex()/hierarchy_mutex() is not necessary for all calls.

Can you clarify here - do you mean "not necessary for any calls"
(calls to what?) or "not necessary for some calls"? I presume the
former.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
