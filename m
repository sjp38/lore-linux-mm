Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 06D3D6B0047
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 03:19:26 -0400 (EDT)
Date: Fri, 13 Mar 2009 00:15:14 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/4] Memory controller soft limit patches (v5)
Message-Id: <20090313001514.75781cc8.akpm@linux-foundation.org>
In-Reply-To: <7e852b228b80d8ba468a49bfb6551b6d.squirrel@webmail-b.css.fujitsu.com>
References: <20090312175603.17890.52593.sendpatchset@localhost.localdomain>
	<7c3bfaf94080838cb7c2f7c54959a9f1.squirrel@webmail-b.css.fujitsu.com>
	<7e852b228b80d8ba468a49bfb6551b6d.squirrel@webmail-b.css.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Fri, 13 Mar 2009 16:07:35 +0900 (JST) "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> > Nack again. I'll update my own version again.
> >
> Sigh, this is in -mm ? okay...I'll update onto -mm as much as I can.
> Very heavy work, maybe.

I dropped them all again.  it appears that quite a few changes are needed
and I don't think we want these patches interfering with other cgroup
and general MM development.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
