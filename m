Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 35F296B00E3
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 02:39:18 -0500 (EST)
Message-ID: <49B0D32A.9040807@cn.fujitsu.com>
Date: Fri, 06 Mar 2009 15:39:22 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] kmemdup_from_user(): introduce
References: <49B0CAEC.80801@cn.fujitsu.com> <20090306072328.GL22605@hack.private>
In-Reply-To: <20090306072328.GL22605@hack.private>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: =?ISO-8859-1?Q?Am=E9rico_Wang?= <xiyou.wangcong@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>> +void *kmemdup_from_user(const void __user *src, size_t len, gfp_t gfp)
>> +{
>> +	void *p;
>> +
>> +	p = kmalloc_track_caller(len, gfp);
> 
> Well, you use kmalloc_track_caller, instead of kmalloc as you showed
> above. :) Why don't you mention this?
> 

Because this changelog is not going to explain what kmalloc_track_caller()
is used for, which has been explained in linux/slab.h ..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
