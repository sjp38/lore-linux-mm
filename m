Message-Id: <99Sep27.090733bst.66305@gateway.ukaea.org.uk>
Date: Mon, 27 Sep 1999 09:08:31 +0100
From: Neil Conway <nconway.list@ukaea.org.uk>
MIME-Version: 1.0
Subject: Re: mm->mmap_sem
References: <Pine.LNX.4.10.9909241040460.12262-100000@imperial.edgeglobal.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: James Simmons <jsimmons@edgeglobal.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

James Simmons wrote:
> 
> I obtained this idea from do_page_fault. This function is called from a
> interrupt when a process actually tries to access memory correct? Even if
> the page does or doesn't exist? 

That's the bit that's tripping you up then.  No page-fault will occur in
general if the page has already been used and hasn't been swapped out
etc.  How bad would performance be if every access to every page caused
an interrupt?

Neil
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
