Date: Thu, 5 Jun 2003 11:21:29 +0200 (CEST)
From: Maciej Soltysiak <solt@dns.toxicfilms.tv>
Subject: Re: 2.5.70-mm4
In-Reply-To: <200306042333.26850.rudmer@legolas.dynup.net>
Message-ID: <Pine.LNX.4.51.0306051120250.17494@dns.toxicfilms.tv>
References: <20030603231827.0e635332.akpm@digeo.com>
 <200306042333.26850.rudmer@legolas.dynup.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rudmer van Dijk <rudmer@legolas.dynup.net>
Cc: Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> I got the following errors with every file that includes
> include/linux/bitops.h
>
> include/linux/bitops.h: In function `generic_hweight64':
> include/linux/bitops.h:118: warning: integer constant is too large for "long"
> type
> include/linux/bitops.h:118: warning: integer constant is too large for "long"
> type
> include/linux/bitops.h:119: warning: integer constant is too large for "long"
<snip>

Same here with debian unstable with gcc-3.3, it started to act like that
since -mm4, mm3 was ok.

> This is on UP, athlon, gcc 3.3
Also UP on P4.

Regards,
Maciej

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
