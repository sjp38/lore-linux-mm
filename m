Date: Thu, 8 Jun 2000 22:47:44 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: Allocating a page of memory with a given physical address
Message-ID: <20000608224744.E3886@redhat.com>
References: <20000608220756Z131165-245+106@kanga.kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20000608220756Z131165-245+106@kanga.kvack.org>; from ttabi@interactivesi.com on Thu, Jun 08, 2000 at 04:44:21PM -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Timur Tabi <ttabi@interactivesi.com>
Cc: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, Jun 08, 2000 at 04:44:21PM -0500, Timur Tabi wrote:

> I have an application that needs to allocate a page of RAM on a given physical
> address.  IOW, say I have a physical address (e.g. 0x0CDB5000 on a 256MB
> machine), and I know (via the mem_map array) that it's not being used by
> anything.  What I need to do know is allocate that page of memory so that no one
> else can allocate it (via a memory allocation function like get_free_page or
> malloc).
> 
> Is this currently possible?

No, nor is it likely to be added without a compelling reason.  Why do 
you need this?

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
