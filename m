Date: Fri, 22 Sep 2000 10:39:29 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: test9-pre5+t9p2-vmpatch VM deadlock during write-intensive
 workload
In-Reply-To: <Pine.LNX.4.21.0009221046300.12532-100000@debella.aszi.sztaki.hu>
Message-ID: <Pine.LNX.4.10.10009221037560.1647-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Molnar Ingo <mingo@debella.ikk.sztaki.hu>
Cc: Rik van Riel <riel@conectiva.com.br>, "David S. Miller" <davem@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Fri, 22 Sep 2000, Molnar Ingo wrote:
> 
> i'm still getting VM related lockups during heavy write load, in
> test9-pre5 + your 2.4.0-t9p2-vmpatch (which i understand as being your
> last VM related fix-patch, correct?). Here is a histogram of such a
> lockup:

Rik, 
 those VM patches are going away RSN if these issues do not get fixed. I'm
really disappointed, and suspect that it would be easier to go back to the
old VM with just page aging added, not your new code that seems to be full
of deadlocks everywhere.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
