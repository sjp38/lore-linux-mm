Subject: Re: [PATCH] replace SYSV shared memory with shm filesystem
References: <qwwvh52ruin.fsf_-_@sap.com> <20000110145913.01335@colin.muc.de> <qwwya9xreu6.fsf@sap.com> <nn66x1wtgh.fsf@code.and.org>
From: Christoph Rohland <hans-christoph.rohland@sap.com>
Date: 11 Jan 2000 13:00:32 +0100
In-Reply-To: James Antill's message of "10 Jan 2000 15:41:02 -0500"
Message-ID: <qwwg0w4rf6n.fsf@sap.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: james@and.org
Cc: Christoph Rohland <hans-christoph.rohland@sap.com>, Andi Kleen <ak@muc.de>, MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

James Antill <james@and.org> writes:

>  If the idea is to integrate the unix domain sockets at some point,
> then I'd like to suggest that _both_ shm and unix domain sockets get a
> subtree. Ie.
> 
> /kernfs/unix_domain_sockets/*
> /kernfs/sysv_shared_memory/*

I think Unix Sockets should use a new instance of the fs and mount it
to a private place.

Greetings
		Christoph
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
