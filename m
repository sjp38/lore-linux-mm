Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 032D86B004D
	for <linux-mm@kvack.org>; Sun,  1 Nov 2009 12:58:31 -0500 (EST)
Message-ID: <4AEDCC42.4040605@redhat.com>
Date: Sun, 01 Nov 2009 12:58:26 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv2 5/5][nit fix] vmscan Make consistent of reclaim bale
 out between do_try_to_free_page and shrink_zone
References: <20091101234614.F401.A69D9226@jp.fujitsu.com> <20091102001210.F40D.A69D9226@jp.fujitsu.com>
In-Reply-To: <20091102001210.F40D.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 11/01/2009 10:13 AM, KOSAKI Motohiro wrote:
> Fix small inconsistent of ">" and">=".

Nice catch.

> Signed-off-by: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
