Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 8BA9B6B005C
	for <linux-mm@kvack.org>; Thu,  8 Dec 2011 01:33:57 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id BD9323EE0AE
	for <linux-mm@kvack.org>; Thu,  8 Dec 2011 15:33:55 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A21B645DE86
	for <linux-mm@kvack.org>; Thu,  8 Dec 2011 15:33:55 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8C3DC45DE83
	for <linux-mm@kvack.org>; Thu,  8 Dec 2011 15:33:55 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7D35C1DB8053
	for <linux-mm@kvack.org>; Thu,  8 Dec 2011 15:33:55 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 224811DB804F
	for <linux-mm@kvack.org>; Thu,  8 Dec 2011 15:33:55 +0900 (JST)
Date: Thu, 8 Dec 2011 15:32:30 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH v4] oom: add tracepoints for oom_score_adj
Message-Id: <20111208153230.9c68eab3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20111208104705.b2e50039.kamezawa.hiroyu@jp.fujitsu.com>
References: <20111207095434.5f2fed4b.kamezawa.hiroyu@jp.fujitsu.com>
	<4EDF99B2.6040007@jp.fujitsu.com>
	<20111208104705.b2e50039.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, rientjes@google.com, dchinner@redhat.com

On Thu, 8 Dec 2011 10:47:05 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Wed, 07 Dec 2011 11:52:02 -0500
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
  - [pid] comm
> >  - pid:comm
> >  - comm:pid
> >  - comm-pid    (ftrace specific)
> > 
> > Why do we need to introduce alternative printing style?
> > 
> 

v4 here
==
