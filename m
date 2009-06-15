Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id BAAD26B004F
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 06:12:16 -0400 (EDT)
Date: Mon, 15 Jun 2009 03:12:37 -0700 (PDT)
Message-Id: <20090615.031237.16489152.davem@davemloft.net>
Subject: Re: 2.6.31-rc1: memory initialization warnings on sparc
From: David Miller <davem@davemloft.net>
In-Reply-To: <a4423d670906150303o353f598dg4eb7b1f181344d8e@mail.gmail.com>
References: <a4423d670906150303o353f598dg4eb7b1f181344d8e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: a.beregalov@gmail.com
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


I know about them, I saw these messages too.

kmalloc() initialization got moved earlier so large swaths of sparc
early initialization need to move from bootmem to kmalloc or similar.

It's just a harmless warning as the bootmem code calls kmalloc()
if that's available already.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
