Date: Thu, 25 Jan 2001 15:16:55 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: ioremap_nocache problem?
Message-ID: <20010125151655.V11607@redhat.com>
References: <3A6D5D28.C132D416@sangate.com> <20010123165117Z131182-221+34@kanga.kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20010123165117Z131182-221+34@kanga.kvack.org>; from ttabi@interactivesi.com on Tue, Jan 23, 2001 at 10:53:51AM -0600
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Timur Tabi <ttabi@interactivesi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Jan 23, 2001 at 10:53:51AM -0600, Timur Tabi wrote:
> 
> My problem is that it's very easy to map memory with ioremap_nocache, but if
> you use iounmap() the un-map it, the entire system will crash.  No one has been
> able to explain that one to me, either.

ioremap*() is only supposed to be used on IO regions or reserved
pages.  If you haven't marked the pages as reserved, then iounmap will
do the wrong thing, so it's up to you to reserve the pages.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
