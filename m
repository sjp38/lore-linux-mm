Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 35AD36B0082
	for <linux-mm@kvack.org>; Mon, 12 Oct 2009 20:31:51 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n9D0VmA7002646
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 13 Oct 2009 09:31:48 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4CDC445DE61
	for <linux-mm@kvack.org>; Tue, 13 Oct 2009 09:31:46 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E50745DE55
	for <linux-mm@kvack.org>; Tue, 13 Oct 2009 09:31:46 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8031C1DB8040
	for <linux-mm@kvack.org>; Tue, 13 Oct 2009 09:31:44 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2F8CE1DB8038
	for <linux-mm@kvack.org>; Tue, 13 Oct 2009 09:31:44 +0900 (JST)
Date: Tue, 13 Oct 2009 09:29:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/2] memcg: improving scalability by reducing lock
 contention at charge/uncharge
Message-Id: <20091013092920.7d509ffa.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <604427e00910111134o6f22f0ddg2b87124dd334ec02@mail.gmail.com>
References: <20091002135531.3b5abf5c.kamezawa.hiroyu@jp.fujitsu.com>
	<604427e00910091737s52e11ce9p256c95d533dc2837@mail.gmail.com>
	<f82dee90d0ab51d5bd33a6c01a9feb17.squirrel@webmail-b.css.fujitsu.com>
	<604427e00910111134o6f22f0ddg2b87124dd334ec02@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Sun, 11 Oct 2009 11:34:39 -0700
Ying Han <yinghan@google.com> wrote:

> 2009/10/10 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> > This patch series is only for "child" cgroup. Sorry, I had to write it
> > clearer. No effects to root.
> >
> 
> Ok, Thanks for making it clearer. :) So Do you mind post the cgroup+memcg
> configuration
> while you are running on your host?
> 

#mount -t cgroup /dev/null /cgroups -omemory
#mkdir /cgroups/A
#echo $$ > /cgroups/A

and run test.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
