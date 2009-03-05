Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 96E716B00B5
	for <linux-mm@kvack.org>; Thu,  5 Mar 2009 04:14:41 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n259Ec5P023472
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 5 Mar 2009 18:14:38 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 495A045DE54
	for <linux-mm@kvack.org>; Thu,  5 Mar 2009 18:14:38 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1018A45DE52
	for <linux-mm@kvack.org>; Thu,  5 Mar 2009 18:14:38 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id B67201DB803C
	for <linux-mm@kvack.org>; Thu,  5 Mar 2009 18:14:37 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6AF991DB8038
	for <linux-mm@kvack.org>; Thu,  5 Mar 2009 18:14:34 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: drop_caches ...
In-Reply-To: <20090305090618.GB23266@ics.muni.cz>
References: <20090305004850.GA6045@localhost> <20090305090618.GB23266@ics.muni.cz>
Message-Id: <20090305181304.6758.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  5 Mar 2009 18:14:33 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Cc: kosaki.motohiro@jp.fujitsu.com, Wu Fengguang <fengguang.wu@intel.com>, Markus <M4rkusXXL@web.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Zdenek Kabelac <zkabelac@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> Hello,
> 
> On Thu, Mar 05, 2009 at 08:48:50AM +0800, Wu Fengguang wrote:
> > Markus, you may want to try this patch, it will have better chance to figure
> > out the hidden file pages.
> 
> just for curiosity, would it be possible to print process name which caused
> the file to be loaded into caches?

impossible.
kernel don't know which process populate page cache.





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
