Subject: Re: Allocating a page of memory with a given physical address
References: <20000608220756Z131165-245+106@kanga.kvack.org>
	<20000608220756Z131165-245+106@kanga.kvack.org>
	<20000608222138Z131165-281+94@kanga.kvack.org>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: Timur Tabi's message of "Thu, 08 Jun 2000 16:58:13 -0500"
Date: 09 Jun 2000 00:15:39 +0200
Message-ID: <yttd7lrq0ok.fsf@serpe.mitica>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Timur Tabi <ttabi@interactivesi.com>
Cc: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>>>>> "timur" == Timur Tabi <ttabi@interactivesi.com> writes:

timur> ** Reply to message from "Stephen C. Tweedie" <sct@redhat.com> on Thu, 8 Jun
timur> 2000 22:47:44 +0100


>> No, nor is it likely to be added without a compelling reason.  Why do 
>> you need this?

timur> Unfortunately, it's part of my company's upcoming product, and I can't give a
timur> detailed explanation.  I understand that such a response does not endear me to
timur> the Linux community, but my hands are tied.  All I can say is that all of us
timur> software guys here have given it a lot of thought, and we're absolutely positive
timur> that we need this functionality.   We need to be able to read/write memory to
timur> specific DIMMs.

Try to grep the kernel for mem_map_reserve uses, it does something
similar, and can be similar to what you want to do.  Notice that you
need to reserve the page *soon* in the boot process.

Later, Juan.

-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
