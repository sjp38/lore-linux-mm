Date: Wed, 29 Mar 2000 14:45:16 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: how text page of executable are shared ?
Message-ID: <20000329144516.A21920@redhat.com>
References: <20000328142253.A16752@redhat.com> <Pine.LNX.4.10.10003281019140.5753-100000@coffee.psychology.mcmaster.ca>, <Pine.LNX.4.10.10003281019140.5753-100000@coffee.psychology.mcmaster.ca>; <20000329020103.I17288@redhat.com> <38E192D1.3D7B642B@uow.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <38E192D1.3D7B642B@uow.edu.au>; from andrewm@uow.edu.au on Wed, Mar 29, 2000 at 05:21:21AM +0000
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <andrewm@uow.edu.au>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Mark Hahn <hahn@coffee.psychology.mcmaster.ca>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Mar 29, 2000 at 05:21:21AM +0000, Andrew Morton wrote:
> > 
> > The swapping should be brief if all is working properly, though, as the
> > shrink_mmap() will rapidly find itself on the second pass over memory
> > and will start finding things which have been aged on the first pass
> > and not used since.
> 
> Interesting.
> 
> Why do you swap active pages out (page_count(page) > 1) when there are
> still (page_count(page) == 1) pages floating about?

We don't.  Scanning the page cache for unreferenced, count==1 pages 
always takes priority over swapping.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
