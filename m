Message-ID: <46ACABBF.10406@redhat.com>
Date: Sun, 29 Jul 2007 11:01:19 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: How can we make page replacement smarter
References: <200707272243.02336.a1426z@gawab.com>	<46AAA25E.7040301@redhat.com>	<200707280717.41250.a1426z@gawab.com>	<46ABF184.40803@redhat.com> <20070729140936.6cd364a9@the-village.bc.nu>
In-Reply-To: <20070729140936.6cd364a9@the-village.bc.nu>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Al Boldi <a1426z@gawab.com>, Chris Snook <csnook@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Alan Cox wrote:
>> Files are different.  File content tends to be grouped
>> in large related chunks, both logically in the file and
>> on disk.  Generally there is a lot more file data on a
>> system than what fits in memory.
> 
> Binary paging patterns don't always look like that unfortunately although
> I suspect we might want to be weighing towards paging out R/O file mapped
> pages earlier simply because they are bigger linear chunks

A properly implemented use-once algorithm should be able
to filter out the spatial locality of reference pages from
the temporal locality of reference ones, though...

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
