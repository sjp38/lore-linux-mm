Date: Fri, 09 Jun 2000 18:04:42 -0500
From: Timur Tabi <ttabi@interactivesi.com>
References: <20000608225108Z131165-245+107@kanga.kvack.org> <Pine.LNX.4.21.0006082003120.22665-100000@duckman.distro.conectiva> <20000608235235Z131165-283+94@kanga.kvack.org>
In-Reply-To: <20000609232058.C28878@pcep-jamie.cern.ch>
References: <20000608235235Z131165-283+94@kanga.kvack.org>; from ttabi@interactivesi.com on Thu, Jun 08, 2000 at 06:29:07PM -0500
Subject: Re: Allocating a page of memory with a given physical address
Message-Id: <20000609230528Z131165-283+98@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

** Reply to message from Jamie Lokier <lk@tantalophile.demon.co.uk> on Fri, 9
Jun 2000 23:20:58 +0200


> Even if you implement that, there will be times when you simply can't
> have the page.  Sometimes the current owner of the page can't allow it
> to be moved.  This happens for vmalloc()ed memory and user processes
> that that use mlock().  This includes MP3 players and security
> products...

That's okay.  If it page is taken, then the caller will have to deal with it. 



--
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
