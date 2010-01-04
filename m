Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 07E40600068
	for <linux-mm@kvack.org>; Sun,  3 Jan 2010 19:37:11 -0500 (EST)
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp03.au.ibm.com (8.14.3/8.13.1) with ESMTP id o040YFhm006919
	for <linux-mm@kvack.org>; Mon, 4 Jan 2010 11:34:15 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o040WjcY1269958
	for <linux-mm@kvack.org>; Mon, 4 Jan 2010 11:32:45 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o040b6Cb012259
	for <linux-mm@kvack.org>; Mon, 4 Jan 2010 11:37:06 +1100
Date: Mon, 4 Jan 2010 06:06:12 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 0/4] cgroup notifications API and memory thresholds
Message-ID: <20100104003612.GF16187@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <cover.1262186097.git.kirill@shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <cover.1262186097.git.kirill@shutemov.name>
Sender: owner-linux-mm@kvack.org
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: containers@lists.linux-foundation.org, linux-mm@kvack.org, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>, Dan Malek <dan@embeddedalley.com>, Vladislav Buzov <vbuzov@embeddedalley.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Alexander Shishkin <virtuoso@slind.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Kirill A. Shutemov <kirill@shutemov.name> [2009-12-30 17:57:55]:

> This patchset introduces eventfd-based API for notifications in cgroups and
> implements memory notifications on top of it.
> 
> It uses statistics in memory controler to track memory usage.
> 
> Output of time(1) on building kernel on tmpfs:
> 
> Root cgroup before changes:
> 	make -j2  506.37 user 60.93s system 193% cpu 4:52.77 total
> Non-root cgroup before changes:
> 	make -j2  507.14 user 62.66s system 193% cpu 4:54.74 total
> Root cgroup after changes (0 thresholds):
> 	make -j2  507.13 user 62.20s system 193% cpu 4:53.55 total
> Non-root cgroup after changes (0 thresholds):
> 	make -j2  507.70 user 64.20s system 193% cpu 4:55.70 total
> Root cgroup after changes (1 thresholds, never crossed):
> 	make -j2  506.97 user 62.20s system 193% cpu 4:53.90 total
> Non-root cgroup after changes (1 thresholds, never crossed):
> 	make -j2  507.55 user 64.08s system 193% cpu 4:55.63 total
> 
> Any comments?

Hi,

I just saw that the notification work for me using the tool you
supplied. One strange thing was that I got notified even though
the amount of data I was using was reducing, so I hit the notification
two ways

        +------------+-----------
                    1G
                ----> (got notified on increase)
                <---- (got notified on decrease)

I am not against the behaviour, but it can be confusing unless
clarified with the event.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
