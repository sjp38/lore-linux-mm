Subject: Re: 2.6.0-mm2
From: Felipe Alfaro Solana <felipe_alfaro@linuxmail.org>
In-Reply-To: <Pine.LNX.4.44.0312291351150.2380-100000@bigblue.dev.mdolabs.com>
References: <Pine.LNX.4.44.0312291351150.2380-100000@bigblue.dev.mdolabs.com>
Content-Type: text/plain
Message-Id: <1072736815.5170.6.camel@teapot.felipe-alfaro.com>
Mime-Version: 1.0
Date: Mon, 29 Dec 2003 23:26:56 +0100
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Davide Libenzi <davidel@xmailserver.org>
Cc: ramon.rey@hispalinux.es, Andrew Morton <akpm@osdl.org>, Linux Kernel Mailinglist <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2003-12-29 at 22:52, Davide Libenzi wrote:
> On Mon, 29 Dec 2003, Felipe Alfaro Solana wrote:
> 
> > The same happens here. cdrecord is broken under -mm, but works fine with
> > plain 2.6.0.
> 
> cdrecord works fine here (-mm1) using hdX=ide-cd and dev=ATAPI:...

Yep, but cdrecord fails when using "cdrecord -dev=/dev/hdx" under -mm
but works perfectly under vanilla 2.6.0.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
