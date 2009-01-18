Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 378606B00A3
	for <linux-mm@kvack.org>; Sun, 18 Jan 2009 17:36:33 -0500 (EST)
Date: Mon, 19 Jan 2009 07:36:23 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2.6.28 1/2] memory: improve find_vma
In-Reply-To: <8c5a844a0901170912l48bab3fuc306bd77622bb53f@mail.gmail.com>
References: <8c5a844a0901170912l48bab3fuc306bd77622bb53f@mail.gmail.com>
Message-Id: <20090120072659.B0A6.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daniel Lowengrub <lowdanie@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi

> -	/* linked list of VM areas per task, sorted by address */
> +	/* doubly linked list of VM areas per task, sorted by address */
>  	struct vm_area_struct *vm_next;
> +	struct vm_area_struct *vm_prev;

if you need "doublly linked list", why don't you use list.h?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
