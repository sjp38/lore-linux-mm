Date: Wed, 26 Apr 2000 11:53:07 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [patch] memory hog protection
Message-ID: <20000426115307.C3792@redhat.com>
References: <Pine.LNX.4.21.0004240728070.3464-100000@duckman.conectiva> <390603EA.7DFC64BA@mandrakesoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <390603EA.7DFC64BA@mandrakesoft.com>; from jgarzik@mandrakesoft.com on Tue, Apr 25, 2000 at 04:45:30PM -0400
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Garzik <jgarzik@mandrakesoft.com>
Cc: riel@nl.linux.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Apr 25, 2000 at 04:45:30PM -0400, Jeff Garzik wrote:
> 
> ...dozen or so smaller processes which are far less important than the
> database server :)

That's exactly the property we need to avoid.  In many cases, when 
you have one large memory hog thrashing away, the one smaller process
which _really_ matters is the shell from which root is trying to sort
out the mess.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
