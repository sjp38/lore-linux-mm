Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id EA22D6B0047
	for <linux-mm@kvack.org>; Sun, 26 Sep 2010 22:01:48 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o8R21j8b009932
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 27 Sep 2010 11:01:45 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8DBB745DE52
	for <linux-mm@kvack.org>; Mon, 27 Sep 2010 11:01:44 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E348F45DE53
	for <linux-mm@kvack.org>; Mon, 27 Sep 2010 11:01:43 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B34111DB8043
	for <linux-mm@kvack.org>; Mon, 27 Sep 2010 11:01:42 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id CCE331DB8037
	for <linux-mm@kvack.org>; Mon, 27 Sep 2010 11:01:41 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Default zone_reclaim_mode = 1 on NUMA kernel is bad forfile/email/web servers
In-Reply-To: <20100921090407.GA11439@csn.ul.ie>
References: <52C8765522A740A4A5C027E8FDFFDFE3@jem> <20100921090407.GA11439@csn.ul.ie>
Message-Id: <20100927110049.6B31.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 27 Sep 2010 11:01:41 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Rob Mueller <robm@fastmail.fm>, linux-kernel@vger.kernel.org, Bron Gondwana <brong@fastmail.fm>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi

> No doubt this is true. The only real difference is that there are more NUMA
> machines running mail/web/file servers now than there might have been in the
> past. The default made sense once upon a time. Personally I wouldn't mind
> the default changing but my preference would be that distribution packages
> installing on NUMA machines would prompt if the default should be changed if it
> is likely to be of benefit for that package (e.g. the mail, file and web ones).

At first impression, I thought this is cute idea. But, after while thinking, I've found some
weak point. The problem is, too many package need to disable zone_reclaim_mode.
zone_reclaim doesn't works fine if an application need large working set rather than
local node size. It mean major desktop applications (e.g. OpenOffice.org, Firefox, GIMP)
need to disable zone_reclaim. It mean even though basic package installation require 
zone_reclaim disabling. Then, this mechanism doesn't works practically. Even though
the user hope to use the machine for hpc, disable zone_reclaim will be turn on anyway.

Probably, opposite switch (default is zone_reclaim=0, and installation MPI library change
to zone_reclaim=1) might works. but I can guess why you don't propose this one.

Hmm....


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
