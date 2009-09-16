Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 99A2D6B004F
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 23:21:02 -0400 (EDT)
Message-ID: <4AB0599B.1090600@redhat.com>
Date: Tue, 15 Sep 2009 23:20:59 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: Isolated(anon) and Isolated(file)
References: <20090915114742.DB79.A69D9226@jp.fujitsu.com>	<Pine.LNX.4.64.0909160047480.4234@sister.anvils>	<20090916091022.DB8C.A69D9226@jp.fujitsu.com> <20090915191957.9e901c38.akpm@linux-foundation.org>
In-Reply-To: <20090915191957.9e901c38.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Wed, 16 Sep 2009 11:09:54 +0900 (JST) KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
>> Subject: [PATCH] Kill Isolated field in /proc/meminfo fix
>>
>> Hugh Dickins pointed out Isolated field dislpay 0kB at almost time.
>> It is only increased at heavy memory pressure case.
> 
> Have we made up our minds yet?
> 
> Below is what remains.  Please check that the changelog is still
> accurate and complete.  If not, please send along a new one?

Looks good to me.  The isolated stats are printed at OOM
time and in /proc/vmstat - just where they belong, IMHO.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
