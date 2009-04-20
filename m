Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 83EFE5F0001
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 05:18:25 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3K9Ieln027559
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 20 Apr 2009 18:18:40 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 32CDE45DE52
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 18:18:40 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id F3A7C45DD72
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 18:18:39 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id CF24A1DB8043
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 18:18:39 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 701041DB803A
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 18:18:39 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH V3] Fix Committed_AS underflow
In-Reply-To: <1240218590-16714-1-git-send-email-ebmunson@us.ibm.com>
References: <1240218590-16714-1-git-send-email-ebmunson@us.ibm.com>
Message-Id: <20090420181617.61B1.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 20 Apr 2009 18:18:38 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Eric B Munson <ebmunson@us.ibm.com>
Cc: kosaki.motohiro@jp.fujitsu.com, dave@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mel@linux.vnet.ibm.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

> This patch makes a small change to an earlier patch by Kosaki Motohiro.
> The threshold calculation was changed to avoid the overhead of calculating
> the number of online cpus each time the threshold is needed.

IIRC, Mel have the patch of kill num_online_cups() calculation cost.
but I can accept your patch because mel patch haven't merged mainline yet.

Thanks :)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
