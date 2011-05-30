Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 226426B0012
	for <linux-mm@kvack.org>; Mon, 30 May 2011 03:35:57 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 6EE913EE0B5
	for <linux-mm@kvack.org>; Mon, 30 May 2011 16:35:53 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4EF0445DE67
	for <linux-mm@kvack.org>; Mon, 30 May 2011 16:35:53 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2ACCC45DE4D
	for <linux-mm@kvack.org>; Mon, 30 May 2011 16:35:53 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1B011E18005
	for <linux-mm@kvack.org>; Mon, 30 May 2011 16:35:53 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D6E371DB802C
	for <linux-mm@kvack.org>; Mon, 30 May 2011 16:35:52 +0900 (JST)
Date: Mon, 30 May 2011 16:29:04 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Bugme-new] [Bug 36192] New: Kernel panic when boot the 2.6.39+
 kernel based off of 2.6.32 kernel
Message-Id: <20110530162904.b78bf354.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110530160114.5a82e590.kamezawa.hiroyu@jp.fujitsu.com>
References: <bug-36192-10286@https.bugzilla.kernel.org/>
	<20110529231948.e1439ce5.akpm@linux-foundation.org>
	<20110530160114.5a82e590.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, qcui@redhat.com, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Li Zefan <lizf@cn.fujitsu.com>

On Mon, 30 May 2011 16:01:14 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Sun, 29 May 2011 23:19:48 -0700
> Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > 
> > (switched to email.  Please respond via emailed reply-to-all, not via the
> > bugzilla web interface).
> > 
> > On Mon, 30 May 2011 02:38:33 GMT bugzilla-daemon@bugzilla.kernel.org wrote:
> > 
> > > https://bugzilla.kernel.org/show_bug.cgi?id=36192
> > > 
> > >            Summary: Kernel panic when boot the 2.6.39+ kernel based off of
> > >                     2.6.32 kernel
> > >            Product: Memory Management
> > >            Version: 2.5
> > >     Kernel Version: 2.6.39+
> > >           Platform: All
> > >         OS/Version: Linux
> > >               Tree: Mainline
> > >             Status: NEW
> > >           Severity: normal
> > >           Priority: P1
> > >          Component: Page Allocator
> > >         AssignedTo: akpm@linux-foundation.org
> > >         ReportedBy: qcui@redhat.com
> > >         Regression: Yes
> > > 
> > > 
> > > Created an attachment (id=60012)
> > >  --> (https://bugzilla.kernel.org/attachment.cgi?id=60012)
> > > kernel panic console output
> > > 
> > > When I updated the kernel from 2.6.32 to 2.6.39+ on a server with AMD
> > > Magny-Cours CPU, the server can not boot the 2.6.39+ kernel successfully. The
> > > console ouput showed 'Kernel panic - not syncing: Attempted to kill the idle
> > > task!' I have tried to set the kernel parameter idle=poll in the grub file. It
> > > still failed to reboot due to the same error. But it can reboot successfully on
> > > the server with Intel CPU. The full console output is attached.
> > > 
> > > Steps to reproduce:
> > > 1. install the 2.6.32 kernel
> > > 2. compile and install the kernel 2.6.39+
> > > 3. reboot
> > > 
> > 
> > hm, this is not good.  Might be memcg-related?
> > 
> 
> yes, and the system may be able to boot with a boot option of cgroup_disable=memory.
> but the problem happens in __alloc_pages_nodemask with NULL pointer access.
> Hmm, doesn't this imply some error in building zone/pgdat ?
> 

I want to see .config and 2.6.32's boot log (dmesg) and 2.6.39+'s boot log
if possible.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
