Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 626C66B004D
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 03:29:20 -0400 (EDT)
Received: from d23relay01.au.ibm.com (d23relay01.au.ibm.com [202.81.31.243])
	by e23smtp02.au.ibm.com (8.13.1/8.13.1) with ESMTP id n2D7RwgH023655
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 18:27:58 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay01.au.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2D7TXPC397322
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 18:29:33 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2D7TFPH030254
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 18:29:15 +1100
Date: Fri, 13 Mar 2009 12:59:10 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/4] Memory controller soft limit patches (v5)
Message-ID: <20090313072910.GN16897@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090312175603.17890.52593.sendpatchset@localhost.localdomain> <7c3bfaf94080838cb7c2f7c54959a9f1.squirrel@webmail-b.css.fujitsu.com> <7e852b228b80d8ba468a49bfb6551b6d.squirrel@webmail-b.css.fujitsu.com> <20090313001514.75781cc8.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090313001514.75781cc8.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

* Andrew Morton <akpm@linux-foundation.org> [2009-03-13 00:15:14]:

> On Fri, 13 Mar 2009 16:07:35 +0900 (JST) "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > > Nack again. I'll update my own version again.
> > >
> > Sigh, this is in -mm ? okay...I'll update onto -mm as much as I can.
> > Very heavy work, maybe.
> 
> I dropped them all again.  it appears that quite a few changes are needed
> and I don't think we want these patches interfering with other cgroup
> and general MM development.
>

Thanks Andrew and I'll send an updated patchset later. I'll fix most
review comments and post v6. Hopefully, Kame's and my thought
processes would merge and we'll be ready for inclusion soon again. 

I don't think v6 will be ready for inclusion yet.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
