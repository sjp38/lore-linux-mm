Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id A7DEC6B002B
	for <linux-mm@kvack.org>; Tue, 25 Sep 2012 20:34:17 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id A239E3EE0BC
	for <linux-mm@kvack.org>; Wed, 26 Sep 2012 09:34:15 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 87CFD45DE58
	for <linux-mm@kvack.org>; Wed, 26 Sep 2012 09:34:15 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 58AAF45DE54
	for <linux-mm@kvack.org>; Wed, 26 Sep 2012 09:34:15 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 415DF1DB8040
	for <linux-mm@kvack.org>; Wed, 26 Sep 2012 09:34:15 +0900 (JST)
Received: from g01jpexchyt04.g01.fujitsu.local (g01jpexchyt04.g01.fujitsu.local [10.128.194.43])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E5D3A1DB802F
	for <linux-mm@kvack.org>; Wed, 26 Sep 2012 09:34:14 +0900 (JST)
Message-ID: <50624D5F.9050008@jp.fujitsu.com>
Date: Wed, 26 Sep 2012 09:33:35 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: hot-added cpu is not asiggned to the correct node
References: <50501E97.2020200@jp.fujitsu.com> <20120924093312.GC28937@mwanda>
In-Reply-To: <20120924093312.GC28937@mwanda>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Dan,

At first, thank you for your comment.

2012/09/24 18:33, Dan Carpenter wrote:
> On Wed, Sep 12, 2012 at 02:33:11PM +0900, Yasuaki Ishimatsu wrote:
>> When I hot-added CPUs and memories simultaneously using container driver,
>> all the hot-added CPUs were mistakenly assigned to node0.
>>
>
> Is this something which used to work correctly?  If so which was the
> most recent working kernel?

The cpu hot-adding is first time on my x86 box. So I don't know
whether old kernel can work well or not. But it seems that x86
does not permit to create memory-less-node. So I guess the problem
occurs on old kernel.

Thanks,
Yasuaki Ishimatsu

> regards,
> dan carpenter
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
