From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14352.41043.903043.50156@dukat.scot.redhat.com>
Date: Fri, 22 Oct 1999 18:35:15 +0100 (BST)
Subject: Re: page faults
In-Reply-To: <Pine.LNX.4.10.9910221054550.23698-100000@imperial.edgeglobal.com>
References: <14352.24920.122613.498709@dukat.scot.redhat.com>
	<Pine.LNX.4.10.9910221054550.23698-100000@imperial.edgeglobal.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: James Simmons <jsimmons@edgeglobal.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, "Benjamin C.R. LaHaise" <blah@kvack.org>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, 22 Oct 1999 10:59:25 -0400 (EDT), James Simmons
<jsimmons@edgeglobal.com> said:

> Thank you for that answer. I remember you told me that threads under
> linux is defined as two processes sharing the same memory. So when a
> minor page fault happens by anyone one process will both process page
> tables get updated? Or does the other process will have a minor page
> itself independent of the other process?

Threads are a special case: there is only one set of page tables, and
the pte will only be faulted in once.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
