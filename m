Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: Why *not* rmap, anyway?
Date: Sun, 5 May 2002 20:38:32 +0200
References: <Pine.LNX.4.44L.0204232145120.1960-100000@imladris.surriel.com>
In-Reply-To: <Pine.LNX.4.44L.0204232145120.1960-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E174Qu0-00048i-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>, Christian Smith <csmith@micromuse.com>
Cc: Joseph A Knapka <jknapka@earthlink.net>, "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wednesday 24 April 2002 02:46, Rik van Riel wrote:
> On Tue, 23 Apr 2002, Christian Smith wrote:
> 
> > The question becomes, how much work would it be to rip out the Linux MM
> > piece-meal, and replace it with an implementation of UVM?
> 
> I doubt we want the Mach pmap layer.
> 
> It should be much easier to reimplement the pageout parts of
> the BSD memory management on top of a simpler reverse mapping
> system.
> 
> You can get that code at  http://surriel.com/patches/

Another aspect of the (Free)BSD mm we probably want to hijack is the process
management, i.e., throttling processes selectively (and in some kind of fair
rotation) to reduce mm thrashing, which is known to improve throughput in high
load situations.

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
