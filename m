Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: Why *not* rmap, anyway?
Date: Tue, 7 May 2002 21:47:28 +0200
References: <Pine.LNX.4.33.0205071625570.1579-100000@erol> <Pine.LNX.4.44L.0205071620270.7447-100000@duckman.distro.conectiva> <20020507192547.GU15756@holomorphy.com>
In-Reply-To: <20020507192547.GU15756@holomorphy.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E175Avp-0000Tm-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>, Rik van Riel <riel@conectiva.com.br>
Cc: Christian Smith <csmith@micromuse.com>, Joseph A Knapka <jknapka@earthlink.net>, "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday 07 May 2002 21:25, William Lee Irwin III wrote:
> Procedural interfaces to pagetable manipulations are largely what
> the BSD pmap and SVR4 HAT layers consisted of, no?

They factor the interface the wrong way for Linux.  You don't want
to have to search for each (pte *) starting from the top of the
structure.  We need to be able to do bulk processing.  The BSD
interface just doesn't accomodate this.

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
