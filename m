Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A20526B00C7
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 00:33:19 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oA95XHBj010750
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 9 Nov 2010 14:33:17 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id DBC7845DE4F
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 14:33:16 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id BD58045DE4E
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 14:33:16 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A6D5D1DB8037
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 14:33:16 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 61F651DB803C
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 14:33:13 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: "BUG: soft lockup - CPU#0 stuck for 61s! [kswapd0:184]"
In-Reply-To: <AANLkTimXSSU7Mc05URg3HsONC4iyDTMVJdRxvQ1fNntH@mail.gmail.com>
References: <AANLkTimXSSU7Mc05URg3HsONC4iyDTMVJdRxvQ1fNntH@mail.gmail.com>
Message-Id: <20101109142733.BC69.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Tue,  9 Nov 2010 14:33:12 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Luke Hutchison <luke.hutch@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

> Hi,
> 
> I just wanted to report a bug upstream that is affecting the latest
> versions of at least both Fedora and Ubuntu. CPUs somehow lock up
> under load, producing errors of the form "BUG: soft lockup - CPU#0
> stuck for 61s! [kswapd0:184]"
> 
> The Fedora Bug report is here:
> https://bugzilla.redhat.com/show_bug.cgi?id=649694 -- however you can
> find lots of references to the error message on other distributions
> (including Ubuntu) by googling  "bug soft lockup cpu stuck".
> 
> Lockups seem to happen on server-class hardware under heavy loads when
> the machine is swapping.  This can lead to the entire machine locking
> up in some reported cases (although so far only individual CPUs seem
> to have locked up in my case, not the entire machine).  The point at
> which the CPU hangs varies -- see the dmesg output I attached to the
> Fedora bug report above.
> 
> My machine is a 12-way Xeon X5680 system with ext3, AFS and XFS
> filesystems (XFS is running on hardware RAID).  Please let me know if
> you need other info that would be helpful to diagnosing the problem.

AFAIK, This isssue was already fixed by Mel.

http://kerneltrap.org/mailarchive/linux-kernel/2010/10/27/4637977



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
