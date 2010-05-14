Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 653E56B01F2
	for <linux-mm@kvack.org>; Fri, 14 May 2010 02:26:09 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4E6Q5Mr022954
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 14 May 2010 15:26:06 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E7FEE45DE6F
	for <linux-mm@kvack.org>; Fri, 14 May 2010 15:25:59 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D8EDF45DE60
	for <linux-mm@kvack.org>; Fri, 14 May 2010 15:25:58 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 11470E08003
	for <linux-mm@kvack.org>; Fri, 14 May 2010 15:25:57 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 26FF4E08001
	for <linux-mm@kvack.org>; Fri, 14 May 2010 15:25:53 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/1] mm: add descriptive comment for TIF_MEMDIE declaration
In-Reply-To: <930863A4-0E91-4994-8EA0-E18361B0113D@dilger.ca>
References: <930863A4-0E91-4994-8EA0-E18361B0113D@dilger.ca>
Message-Id: <20100514152557.218F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 14 May 2010 15:25:52 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andreas Dilger <adilger@dilger.ca>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, "linux-kernel@vger.kernel.org Mailinglist" <linux-kernel@vger.kernel.org>, trivial@kernel.org
List-ID: <linux-mm.kvack.org>

> From: Andreas Dilger <adilger@dilger.ca>
> 
> Add descriptive comment for TIF_MEMDIE task flag declaration.
> 
> Signed-off-by: Andreas Dilger <adilger@dilger.ca>

ack.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
