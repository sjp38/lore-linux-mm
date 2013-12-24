Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id 3D3A56B0031
	for <linux-mm@kvack.org>; Mon, 23 Dec 2013 22:01:19 -0500 (EST)
Received: by mail-ob0-f174.google.com with SMTP id wn1so6219266obc.33
        for <linux-mm@kvack.org>; Mon, 23 Dec 2013 19:01:19 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id v5si16804682oep.46.2013.12.23.19.01.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 23 Dec 2013 19:01:18 -0800 (PST)
Message-ID: <52B8F8F6.1080500@oracle.com>
Date: Mon, 23 Dec 2013 22:01:10 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: kernel BUG at include/linux/swapops.h:131!
References: <52B1C143.8080301@oracle.com> <52B871B2.7040409@oracle.com> <20131224025127.GA2835@lge.com>
In-Reply-To: <20131224025127.GA2835@lge.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, khlebnikov@openvz.org, LKML <linux-kernel@vger.kernel.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Bob Liu <bob.liu@oracle.com>

On 12/23/2013 09:51 PM, Joonsoo Kim wrote:
> On Mon, Dec 23, 2013 at 12:24:02PM -0500, Sasha Levin wrote:
>> >Ping?
>> >
>> >I've also Cc'ed the "this page shouldn't be locked at all" team.
> Hello,
>
> I can't find the reason of this problem.
> If it is reproducible, how about bisecting?

While it reproduces under fuzzing it's pretty hard to bisect it with
the amount of issues uncovered by trinity recently.

I can add any debug code to the site of the BUG if that helps.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
