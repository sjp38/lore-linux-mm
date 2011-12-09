Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 759386B004F
	for <linux-mm@kvack.org>; Thu,  8 Dec 2011 19:34:33 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 0C8BD3EE0C2
	for <linux-mm@kvack.org>; Fri,  9 Dec 2011 09:34:32 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E0DCD45DE3E
	for <linux-mm@kvack.org>; Fri,  9 Dec 2011 09:34:31 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C889F45DE86
	for <linux-mm@kvack.org>; Fri,  9 Dec 2011 09:34:31 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id BB4311DB804F
	for <linux-mm@kvack.org>; Fri,  9 Dec 2011 09:34:31 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6882B1DB8052
	for <linux-mm@kvack.org>; Fri,  9 Dec 2011 09:34:31 +0900 (JST)
Date: Fri, 9 Dec 2011 09:33:23 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] oom: add tracepoints for oom_score_adj
Message-Id: <20111209093323.977284db.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20111209084103.e3fea1f7.kamezawa.hiroyu@jp.fujitsu.com>
References: <20111207095434.5f2fed4b.kamezawa.hiroyu@jp.fujitsu.com>
	<4EDF99B2.6040007@jp.fujitsu.com>
	<20111208104705.b2e50039.kamezawa.hiroyu@jp.fujitsu.com>
	<4EE0F4EF.4010301@jp.fujitsu.com>
	<20111209084103.e3fea1f7.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, rientjes@google.com, dchinner@redhat.com

On Fri, 9 Dec 2011 08:41:03 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Thu, 08 Dec 2011 12:33:35 -0500
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
 see Documentation/trace/event.txt 5. Event filgtering
> > 
> > Now, both ftrace and perf have good filter feature. Isn't this enough?
> > 
> 
> Could you make patch ? Then, I stop this and go other probelm.
> 

Hmm, core of patch should be like this. But need some works on

 - How to debug oom in Documenation especially for trace-cmd users.
 - Other trace points sutable for 'task' tracing. maybe 'exit, stop, freeze' ?
 - at creating new task, what other members should be printed out ?
 - At renaming...don't we need reason for renaming ?

Hm. BTW, do you know how to write filtering in
/etc/sysconfig/trace-cmd.config ?
