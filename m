Date: Mon, 24 Apr 2000 19:08:49 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: mmap64?
Message-ID: <20000424190849.C1566@redhat.com>
References: <Pine.LNX.4.21.0004221830080.20850-100000@duckman.conectiva> <B527A1E9.56B9%jason.titus@av.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <B527A1E9.56B9%jason.titus@av.com>; from jason.titus@av.com on Sat, Apr 22, 2000 at 06:37:29PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jason Titus <jason.titus@av.com>
Cc: riel@nl.linux.org, linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Sat, Apr 22, 2000 at 06:37:29PM -0700, Jason Titus wrote:

> Well, seems like if we are allowing processes to access 3+GB, we should be
> able to mmap a similar range.  Also, I don't know too much about the PAE 36
> bit PIII stuff but I had thought it might give us some additional address
> space...

No, the PAE36 architecture only increases the addressable physical 
memory on Intel CPUs.  It does nothing to change the virtual address
space.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
