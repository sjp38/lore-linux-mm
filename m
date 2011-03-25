Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id B01298D0040
	for <linux-mm@kvack.org>; Fri, 25 Mar 2011 03:50:46 -0400 (EDT)
Message-ID: <4D8C4953.8020808@kernel.dk>
Date: Fri, 25 Mar 2011 08:50:43 +0100
From: Jens Axboe <axboe@kernel.dk>
MIME-Version: 1.0
Subject: Re: [Q] PGPGIN underflow?
References: <20110324105307.1AF3.A69D9226@jp.fujitsu.com> <20110324095735.61bfa370.randy.dunlap@oracle.com>
In-Reply-To: <20110324095735.61bfa370.randy.dunlap@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2011-03-24 17:57, Randy Dunlap wrote:
> On Thu, 24 Mar 2011 10:52:54 +0900 (JST) KOSAKI Motohiro wrote:
> 
>> Hi all,
>>
>> Recently, vmstast show crazy big "bi" value even though the system has
>> no stress. Is this known issue?
>>
>> Thanks.
> 
> underflow?  also looks like -3 or -ESRCH.
> 
> Adding Jens in case he has any idea about it.

First question, what does 'recently' mean? In other words, in what
kernel did you first notice this behaviour?

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
