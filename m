Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id D88B86B01FD
	for <linux-mm@kvack.org>; Thu,  8 Apr 2010 23:23:54 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o393Np9w015190
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 9 Apr 2010 12:23:51 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2D44F45DE54
	for <linux-mm@kvack.org>; Fri,  9 Apr 2010 12:23:51 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id C502545DE57
	for <linux-mm@kvack.org>; Fri,  9 Apr 2010 12:23:49 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9193B1DB8061
	for <linux-mm@kvack.org>; Fri,  9 Apr 2010 12:23:49 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 046CA1DB805A
	for <linux-mm@kvack.org>; Fri,  9 Apr 2010 12:23:49 +0900 (JST)
Date: Fri, 9 Apr 2010 12:20:01 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] fix cgroup procs documentation
Message-Id: <20100409122001.60967001.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4BBE9D58.2010602@cn.fujitsu.com>
References: <20100409121143.9610dc8f.kamezawa.hiroyu@jp.fujitsu.com>
	<4BBE9D58.2010602@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "menage@google.com" <menage@google.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 09 Apr 2010 11:22:00 +0800
Li Zefan <lizf@cn.fujitsu.com> wrote:

> KAMEZAWA Hiroyuki wrote:
> > 2.6.33's Documentation has the same wrong information. So, I CC'ed to stable.
> > If people believe this information, they'll usr cgroup.procs file and will
> > see cgroup doesn'w work as expected.
> > The patch itself is against -mm.
> > 
> > ==
> > Writing to cgroup.procs is not supported now.
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  Documentation/cgroups/cgroups.txt |    3 +--
> >  1 file changed, 1 insertion(+), 2 deletions(-)
> > 
> > Index: mmotm-temp/Documentation/cgroups/cgroups.txt
> > ===================================================================
> > --- mmotm-temp.orig/Documentation/cgroups/cgroups.txt
> > +++ mmotm-temp/Documentation/cgroups/cgroups.txt
> > @@ -235,8 +235,7 @@ containing the following files describin
> >   - cgroup.procs: list of tgids in the cgroup.  This list is not
> >     guaranteed to be sorted or free of duplicate tgids, and userspace
> >     should sort/uniquify the list if this property is required.
> > -   Writing a tgid into this file moves all threads with that tgid into
> > -   this cgroup.
> > +   This is a read-only file, now.
> 
> I think the better wording is "for now". :)
> 
ok. BTW, does anyone work on this ?
==

Writing to cgroup.procs is not supported now.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 Documentation/cgroups/cgroups.txt |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

Index: mmotm-temp/Documentation/cgroups/cgroups.txt
===================================================================
--- mmotm-temp.orig/Documentation/cgroups/cgroups.txt
+++ mmotm-temp/Documentation/cgroups/cgroups.txt
@@ -235,8 +235,7 @@ containing the following files describin
  - cgroup.procs: list of tgids in the cgroup.  This list is not
    guaranteed to be sorted or free of duplicate tgids, and userspace
    should sort/uniquify the list if this property is required.
-   Writing a tgid into this file moves all threads with that tgid into
-   this cgroup.
+   This is a read-only file, for now.
  - notify_on_release flag: run the release agent on exit?
  - release_agent: the path to use for release notifications (this file
    exists in the top cgroup only)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
