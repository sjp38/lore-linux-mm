Received: from bigblue.dev.mdolabs.com
	by xmailserver.org with [XMail 1.18 (Linux/Ix86) ESMTP Server]
	id <SEF4ED> for <linux-mm@kvack.org> from <davidel@xmailserver.org>;
	Mon, 29 Dec 2003 13:52:26 -0800
Date: Mon, 29 Dec 2003 13:52:24 -0800 (PST)
From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: 2.6.0-mm2
In-Reply-To: <1072731446.5170.4.camel@teapot.felipe-alfaro.com>
Message-ID: <Pine.LNX.4.44.0312291351150.2380-100000@bigblue.dev.mdolabs.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Felipe Alfaro Solana <felipe_alfaro@linuxmail.org>
Cc: ramon.rey@hispalinux.es, Andrew Morton <akpm@osdl.org>, Linux Kernel Mailinglist <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 29 Dec 2003, Felipe Alfaro Solana wrote:

> The same happens here. cdrecord is broken under -mm, but works fine with
> plain 2.6.0.

cdrecord works fine here (-mm1) using hdX=ide-cd and dev=ATAPI:...



- Davide


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
