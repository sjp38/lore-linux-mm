Subject: Re: limit on number of kmapped pages
References: <Pine.LNX.3.96.1010123205643.7482A-100000@kanga.kvack.org> <y7r7l3ldzxp.fsf@sytry.doc.ic.ac.uk>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: 24 Jan 2001 07:27:05 -0700
In-Reply-To: David Wragg's message of "24 Jan 2001 10:09:22 +0000"
Message-ID: <m1n1chdo06.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Wragg <dpw@doc.ic.ac.uk>
Cc: "Benjamin C.R. LaHaise" <blah@kvack.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

David Wragg <dpw@doc.ic.ac.uk> writes:

> I'd still like to know what the basis for the current kmap limit
> setting is.

Mostly at one point kmap_atomic was all there was.  It was only the
difficulty of implementing copy_from_user with kmap_atomic that convinced
people we needed something more.  So actually if we can kmap several
megabyte at once the kmap limit is quite high.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
