Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id BB9E96B004D
	for <linux-mm@kvack.org>; Wed, 27 May 2009 03:04:29 -0400 (EDT)
Received: from mlsv2.hitachi.co.jp (unknown [133.144.234.166])
	by mail4.hitachi.co.jp (Postfix) with ESMTP id 9613333CC8
	for <linux-mm@kvack.org>; Wed, 27 May 2009 16:04:31 +0900 (JST)
Message-ID: <4A1CE5F5.7080207@hitachi.com>
Date: Wed, 27 May 2009 16:04:21 +0900
From: Satoru Moriya <satoru.moriya.br@hitachi.com>
MIME-Version: 1.0
Subject: Re: Problem with oom-killer in memcg
References: <4A1BBEB3.1010701@hitachi.com> <20090527101039.f9de2229.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090527101039.f9de2229.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: linux-mm@kvack.org, satoshi.oshima.fk@hitachi.com, taketoshi.sakuraba.hc@hitachi.com
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:

> How many cpus are you using ?

I'm using Xeon E5345(4 core).
 
> I think Balbir (and other people) is planning to add "oom handler" for memcg
> or oom handler cgroup. But we need more study.

Thank you for sharing that with me.

> I assume that you use x86. If so, current bahavior is a bit complicated.
> 
> do_page_fault()
>    -> allocate and charge memory account
>          -> memcg's oom kill is called
>               -> no progress.
> User says "don't use OOM Kill" but no other way than "OOM Kill"
> 
> We don't have much choices here..
>    - kill in force ?
>    - add some sleep ?
>    - freeze cgroup under OOM ? (this seems not easy)
>    - Ask admin to increase size of memory limit ?
> 
> Thank you for reporting, but I can't think of quick fix right now.
> I'll remember this in my TO-DO List.

Ok, thank you very much.

-- 
--- 
Satoru MORIYA
Linux Technology Center
Hitachi, Ltd., Systems Development Laboratory
E-mail: satoru.moriya.br@hitachi.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
