Date: Thu, 20 Dec 2001 20:45:24 -0500
From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: [RFC] Concept: Active/busy "reverse" mapping
Message-ID: <20011220204524.K6276@redhat.com>
References: <Pine.LNX.4.33L.0112200121290.15741-100000@imladris.surriel.com> <200112210107.fBL17nL10142@maild.telia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200112210107.fBL17nL10142@maild.telia.com>; from roger.larsson@norran.net on Fri, Dec 21, 2001 at 02:05:26AM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Larsson <roger.larsson@norran.net>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Dec 21, 2001 at 02:05:26AM +0100, Roger Larsson wrote:
> The goal of this code is to make sure that used pages are marked as such.
> 
> This is accomplished by:
> 
> * When a process is descheduled - look in its mm for used pages - update 
> corresponding page. (Done at most once per tick)

Interesting.  The same effect is acheived by the reverse mapping code on 
a global scale while addressing the issue of how to figure out what extent 
memory pressure is needed on the page tables.

		-ben
-- 
Fish.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
