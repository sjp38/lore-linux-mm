Date: Wed, 12 Sep 2007 17:54:45 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 18 of 24] run panic the same way in both places
In-Reply-To: <040cab5c8aafe1efcb6f.1187786945@v2.random>
Message-ID: <Pine.LNX.4.64.0709121754170.4489@schroedinger.engr.sgi.com>
References: <040cab5c8aafe1efcb6f.1187786945@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, 22 Aug 2007, Andrea Arcangeli wrote:

> The other panic is called after releasing some core global lock, that
> sounds safe to have for both panics (just in case panic tries to do
> anything more than oops does).

Extract a common function for panicing instead? That way we have only one 
place where we can mess things up.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
