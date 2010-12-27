Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C0B1B6B0087
	for <linux-mm@kvack.org>; Mon, 27 Dec 2010 20:50:08 -0500 (EST)
Date: Sun, 26 Dec 2010 18:13:19 -0800
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: mmotm 2010-12-23-16-58 uploaded
Message-Id: <20101226181319.6ae709d9.randy.dunlap@oracle.com>
In-Reply-To: <201012240132.oBO1W8Ub022207@imap1.linux-foundation.org>
References: <201012240132.oBO1W8Ub022207@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, Alex Dubov <oakad@yahoo.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 23 Dec 2010 16:58:58 -0800 akpm@linux-foundation.org wrote:

> The mm-of-the-moment snapshot 2010-12-23-16-58 has been uploaded to
> 
>    http://userweb.kernel.org/~akpm/mmotm/
> 
> and will soon be available at
> 
>    git://zen-kernel.org/kernel/mmotm.git
> 
> It contains the following patches against 2.6.37-rc7:

> memstick-factor-out-transfer-initiating-functionality-in-mspro_blockc.patch

drivers/memstick/core/mspro_block.c:1090: warning: format '%x' expects type 'unsigned int', but argument 7 has type 'size_t'

change "size %x" to "size %zx"

---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
desserts:  http://www.xenotime.net/linux/recipes/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
