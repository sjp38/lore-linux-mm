Date: Wed, 26 Nov 2003 14:40:12 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: 2.6.0-test10-mm1
Message-ID: <190230000.1069886412@flay>
In-Reply-To: <1069885712.5219.4.camel@laptop.fenrus.com>
References: <20031125211518.6f656d73.akpm@osdl.org> <20031126085123.A1952@infradead.org> <20031126044251.3b8309c1.akpm@osdl.org> <20031126130936.A5275@infradead.org> <20031126052900.17542bb3.akpm@osdl.org> <20031126132505.C5477@infradead.org> <20031126190718.GB1566@mis-mike-wstn.matchmail.com> <1069885712.5219.4.camel@laptop.fenrus.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjan@fenrus.demon.nl>, Mike Fedyk <mfedyk@matchmail.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> Are you trying to say that something that was ported from AIX is a derived
>> work because it has to read kernel internals to get its job done?
> 
> part of it certainly can be. The part that glues directly to linux,
> since I doubt the code just plugged in ...

Not that I have any intention of defending what they're doing or binary
modules or whatever, but ... isn't that the glue layer ... which *IS*
GPL'ed as far as I understand it? OK, so it might be offensively ugly,
but that wasn't a license violation at last count ;-)

M.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
