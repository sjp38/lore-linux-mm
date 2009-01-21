Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C1EF56B0044
	for <linux-mm@kvack.org>; Wed, 21 Jan 2009 05:43:53 -0500 (EST)
Received: from zps36.corp.google.com (zps36.corp.google.com [172.25.146.36])
	by smtp-out.google.com with ESMTP id n0LAhogV011378
	for <linux-mm@kvack.org>; Wed, 21 Jan 2009 10:43:50 GMT
Received: from rv-out-0708.google.com (rvfc5.prod.google.com [10.140.180.5])
	by zps36.corp.google.com with ESMTP id n0LAhkJ2018871
	for <linux-mm@kvack.org>; Wed, 21 Jan 2009 02:43:46 -0800
Received: by rv-out-0708.google.com with SMTP id c5so4218128rvf.34
        for <linux-mm@kvack.org>; Wed, 21 Jan 2009 02:43:46 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20090121193248.94aecb10.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090108182556.621e3ee6.kamezawa.hiroyu@jp.fujitsu.com>
	 <20090108183529.b4fd99f4.kamezawa.hiroyu@jp.fujitsu.com>
	 <6599ad830901131848gf7f6996iead1276bc50753b8@mail.gmail.com>
	 <20090114120044.2ecf13db.kamezawa.hiroyu@jp.fujitsu.com>
	 <6599ad830901131905ie10e4bl5168ab7f337b27e1@mail.gmail.com>
	 <20090114121205.1bb913aa.kamezawa.hiroyu@jp.fujitsu.com>
	 <20090120194735.cc52c5e0.kamezawa.hiroyu@jp.fujitsu.com>
	 <6599ad830901210200q77b2553ag35f706c321a18d83@mail.gmail.com>
	 <20090121193248.94aecb10.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 21 Jan 2009 02:43:44 -0800
Message-ID: <6599ad830901210243k433f618bva4ec756b769be4d4@mail.gmail.com>
Subject: Re: [RFC][PATCH 4/4] cgroup-memcg fix frequent EBUSY at rmdir v2
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 21, 2009 at 2:32 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
> Hmm, subsystem may return -EPERM or some..
> I'll change this to
>
>  if (!ret)
>    return ret;

You mean

if (ret)
  return ret;

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
