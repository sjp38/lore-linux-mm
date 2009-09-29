Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 874F66B005A
	for <linux-mm@kvack.org>; Mon, 28 Sep 2009 21:53:50 -0400 (EDT)
Received: by ywh39 with SMTP id 39so5663908ywh.12
        for <linux-mm@kvack.org>; Mon, 28 Sep 2009 19:06:13 -0700 (PDT)
Message-ID: <4AC16B8F.1060308@gmail.com>
Date: Tue, 29 Sep 2009 10:06:07 +0800
From: Huang Shijie <shijie8@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] rmap : tidy the code
References: <1254128590-27826-1-git-send-email-shijie8@gmail.com>	 <Pine.LNX.4.64.0909281131460.14446@sister.anvils> <8acda98c0909280430w2700826cu55f9629bafab066f@mail.gmail.com>
In-Reply-To: <8acda98c0909280430w2700826cu55f9629bafab066f@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nikita Danilov <danilov@gmail.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nikita Danilov wrote:
> I agree that adding EFAULT check into page_check_address() is better.
> The only call-site that does not call vma_address() before
> page_check_address() is __xip_unmap() and it explicitly BUG_ON()s on
> the same condition.
>
>   
If adding vma_address() into page_check_address() ,  it's  bad  for 
__xip_unmap to change its code.
__xip_unmap must fake a page to satisfy the new "page_check_address()".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
