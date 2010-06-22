Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 9BAB86B0071
	for <linux-mm@kvack.org>; Tue, 22 Jun 2010 14:21:45 -0400 (EDT)
Message-ID: <4C20FF34.3080208@redhat.com>
Date: Tue, 22 Jun 2010 14:21:40 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [Patch] Call cond_resched() at bottom of main look in balance_pgdat()
References: <1276800520.8736.236.camel@dhcp-100-19-198.bos.redhat.com> <20100618093954.FBE7.A69D9226@jp.fujitsu.com>
In-Reply-To: <20100618093954.FBE7.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Larry Woodman <lwoodman@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 06/21/2010 07:45 AM, KOSAKI Motohiro wrote:

> kosaki note: This seems regression caused by commit bb3ab59683
> (vmscan: stop kswapd waiting on congestion when the min watermark is
>   not being met)
> 
> Signed-off-by: Larry Woodman<lwoodman@redhat.com>
> Reviewed-by: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
