Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 9BF3F6B0038
	for <linux-mm@kvack.org>; Fri, 20 Mar 2015 15:47:03 -0400 (EDT)
Received: by pdbni2 with SMTP id ni2so117592881pdb.1
        for <linux-mm@kvack.org>; Fri, 20 Mar 2015 12:47:03 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id fn4si10876377pab.203.2015.03.20.12.47.01
        for <linux-mm@kvack.org>;
        Fri, 20 Mar 2015 12:47:02 -0700 (PDT)
Date: Fri, 20 Mar 2015 15:47:00 -0400 (EDT)
Message-Id: <20150320.154700.1250039074828760104.davem@davemloft.net>
Subject: Re: 4.0.0-rc4: panic in free_block
From: David Miller <davem@davemloft.net>
In-Reply-To: <550C6151.8070803@oracle.com>
References: <550C5078.8040402@oracle.com>
	<CA+55aFyQWa0PjT-3y-HB9P-UAzThrZme5gj1P6P6hMTTF9cMtA@mail.gmail.com>
	<550C6151.8070803@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david.ahern@oracle.com
Cc: torvalds@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org

From: David Ahern <david.ahern@oracle.com>
Date: Fri, 20 Mar 2015 12:05:05 -0600

> DaveM: do you mind if I submit a patch to change the default for sparc
> to SLUB?

I think we're jumping the gun about all of this, and doing anything
with default Kconfig settings would be entirely premature until we
know what the real bug is.

On my T4-2 I've used nothing but SLAB and haven't hit any of these
problems.  I can't even remember the last time I turned SLUB on,
and it's just because I'm lazy.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
