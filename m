Date: Thu, 12 Oct 2000 00:37:29 -0400 (EDT)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: [RFC] atomic pte updates for x86 smp
In-Reply-To: <200010120406.VAA07624@pizda.ninka.net>
Message-ID: <Pine.LNX.3.96.1001012003348.23767A-100000@kanga.kvack.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: torvalds@transmeta.com, tytso@mit.edu, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 11 Oct 2000, David S. Miller wrote:

>    It's safe because of how x86s hardware works
> 
> What about other platforms?

If atomic ops don't work, then software dirty bits are still an option
(read as: it shouldn't break RISC CPUs).

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
