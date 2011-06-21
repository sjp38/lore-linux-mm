Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 76FFD6B015A
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 01:27:50 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id E7AC33EE0BC
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 14:27:47 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id CD88B45DE95
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 14:27:47 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B48AB45DE8F
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 14:27:47 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A75701DB803E
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 14:27:47 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 724961DB803C
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 14:27:47 +0900 (JST)
Message-ID: <4E002BD0.3000003@jp.fujitsu.com>
Date: Tue, 21 Jun 2011 14:27:44 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 03/12] vmscan: reduce wind up shrinker->nr when shrinker
 can't do work
References: <1306998067-27659-1-git-send-email-david@fromorbit.com> <1306998067-27659-4-git-send-email-david@fromorbit.com> <4DFE997C.2060805@jp.fujitsu.com> <20110621050914.GO32466@dastard>
In-Reply-To: <20110621050914.GO32466@dastard>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com

>> I mean, currently some mm folks plan to enhance shrinker. So,
>> sharing benchmark may help to avoid an accidental regression.
> 
> I predict that I will have some bug reporting to do in future. ;)

Ok, I have no objection. thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
