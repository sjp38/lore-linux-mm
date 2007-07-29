Date: Sun, 29 Jul 2007 14:09:36 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: How can we make page replacement smarter
Message-ID: <20070729140936.6cd364a9@the-village.bc.nu>
In-Reply-To: <46ABF184.40803@redhat.com>
References: <200707272243.02336.a1426z@gawab.com>
	<46AAA25E.7040301@redhat.com>
	<200707280717.41250.a1426z@gawab.com>
	<46ABF184.40803@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Al Boldi <a1426z@gawab.com>, Chris Snook <csnook@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Files are different.  File content tends to be grouped
> in large related chunks, both logically in the file and
> on disk.  Generally there is a lot more file data on a
> system than what fits in memory.

Binary paging patterns don't always look like that unfortunately although
I suspect we might want to be weighing towards paging out R/O file mapped
pages earlier simply because they are bigger linear chunks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
