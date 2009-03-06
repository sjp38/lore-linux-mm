Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 7B4276B00F6
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 04:02:54 -0500 (EST)
Message-ID: <49B0E6A9.9020702@cn.fujitsu.com>
Date: Fri, 06 Mar 2009 17:02:33 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] kmemdup_from_user(): introduce
References: <49B0CAEC.80801@cn.fujitsu.com> <20090306082056.GB3450@x200.localdomain> <49B0DE89.9000401@cn.fujitsu.com> <20090306090313.GB4225@x200.localdomain>
In-Reply-To: <20090306090313.GB4225@x200.localdomain>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>> Why not if we have good reasons? And I don't think we can call this
>> "happen to" if there are 250+ of them?
> 
> Please, read through them. This "250+" number suddenly will become
> like 20, because wrapper is not good enough.
> 

I did read most of them roughly, and it will be at least 50.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
