From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14365.32809.373791.822355@dukat.scot.redhat.com>
Date: Mon, 1 Nov 1999 11:57:29 +0000 (GMT)
Subject: Re: page faults
In-Reply-To: <Pine.LNX.4.10.9910291049300.17696-100000@imperial.edgeglobal.com>
References: <19991026110558.A1588@uni-koblenz.de>
	<Pine.LNX.4.10.9910291049300.17696-100000@imperial.edgeglobal.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: James Simmons <jsimmons@edgeglobal.com>
Cc: Ralf Baechle <ralf@uni-koblenz.de>, "Eric W. Biederman" <ebiederm+eric@ccr.net>, "Stephen C. Tweedie" <sct@redhat.com>, "Benjamin C.R. LaHaise" <blah@kvack.org>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, 29 Oct 1999 10:52:57 -0400 (EDT), James Simmons
<jsimmons@edgeglobal.com> said:

> Its about proper virtualization. Imagine if userland would have to
> negotate access to hard drives. 

As soon as you start to memory map the files, it does.  The kernel has
no business enforcing user-level transactions to virtual memory.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
