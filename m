Date: Fri, 20 Apr 2001 14:44:32 +0200 (MET DST)
From: Szabolcs Szakacsits <szaka@f-secure.com>
Subject: Re: suspend processes at load (was Re: a simple OOM ...) 
In-Reply-To: <200104191947.f3JJl2M16392@eng2.sequent.com>
Message-ID: <Pine.LNX.4.30.0104201434510.20939-100000@fs131-224.f-secure.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gerrit Huizenga <gerrit@us.ibm.com>
Cc: Rik van Riel <riel@conectiva.com.br>, Dave McCracken <dmc@austin.ibm.com>, "James A. Sutherland" <jas88@cam.ac.uk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 19 Apr 2001, Gerrit Huizenga wrote:

> Other options to think about here include tuning/limiting a process's
> working set size based on page fault frequency, adjusting the

Heavy paging != thrasing. You even can't suppose major faults are really
major ones.

	Szaka


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
