Subject: Re: mmap64?
References: <B527A1E9.56B9%jason.titus@av.com>
From: Christoph Rohland <hans-christoph.rohland@sap.com>
Date: 23 Apr 2000 10:11:44 +0200
In-Reply-To: Jason Titus's message of "Sat, 22 Apr 2000 18:37:29 -0700"
Message-ID: <qwwbt312q4f.fsf@sap.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jason Titus <jason.titus@av.com>
Cc: riel@nl.linux.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Jason Titus <jason.titus@av.com> writes:

> Well, seems like if we are allowing processes to access 3+GB, we should be
> able to mmap a similar range.  Also, I don't know too much about the PAE 36
> bit PIII stuff but I had thought it might give us some additional address
> space...

No, the user space address space is not changed.

Greetings
		Christoph

-- 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
