Date: Wed, 5 Nov 2008 16:54:05 +0000
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: mmap: is default non-populating behavior stable?
Message-ID: <20081105165405.777ab502@lxorguk.ukuu.org.uk>
In-Reply-To: <Pine.LNX.4.64.0811051613400.21353@blonde.site>
References: <490F73CD.4010705@gmail.com>
	<1225752083.7803.1644.camel@twins>
	<490F8005.9020708@redhat.com>
	<491070B5.2060209@nortel.com>
	<1225814820.7803.1672.camel@twins>
	<20081104162820.644b1487@lxorguk.ukuu.org.uk>
	<49107D98.9080201@gmail.com>
	<Pine.LNX.4.64.0811051613400.21353@blonde.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: "Eugene V. Lyubimkin" <jackyf.devel@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Chris Friesen <cfriesen@nortel.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> (Every year or so we do wonder whether to change an extending mremap
> of a MAP_SHARED|MAP_ANONYMOUS object to extend the object itself instead
> of just SIGBUSing on the extension: but I've so far remained conservative
> about that, and Eugene appears to be thinking of more ordinary files.)

Try an mremap of a VM_GROWS* mapping and all the other things of this
nature. I would say our current behaviour is not what might be expected
by users. The extending an object case is just one example of weird
behaviour.

Alan


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
