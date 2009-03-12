Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id CD0C46B0047
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 01:33:39 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2C5Xb6K020953
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 12 Mar 2009 14:33:37 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 061AA45DD7B
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 14:33:37 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D8DA545DD78
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 14:33:36 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C14B0E08001
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 14:33:36 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 81AED1DB8045
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 14:33:33 +0900 (JST)
Date: Thu, 12 Mar 2009 14:32:12 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 0/5] memcg softlimit (Another one) v4
Message-Id: <20090312143212.50818cd5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090312050423.GI23583@balbir.in.ibm.com>
References: <20090312095247.bf338fe8.kamezawa.hiroyu@jp.fujitsu.com>
	<20090312034647.GA23583@balbir.in.ibm.com>
	<20090312133949.130b20ed.kamezawa.hiroyu@jp.fujitsu.com>
	<20090312050423.GI23583@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 12 Mar 2009 10:34:23 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> Not yet.. you just posted it. I am testing my v5, which I'll post
> soon. I am seeing very good results with v5. I'll test yours later
> today.
> 

If "hooks" to usual path doesn't exist and there are no global locks,
I don't have much concern with your version.
But 'sorting' seems to be overkill to me.

I'm sorry if my responce to your patch is delayed. I may not be in office.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
