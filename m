Date: Tue, 7 May 2002 12:53:04 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Why *not* rmap, anyway?
Message-ID: <20020507195304.GX15756@holomorphy.com>
References: <20020507192547.GU15756@holomorphy.com> <Pine.LNX.4.44L.0205071648210.7447-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44L.0205071648210.7447-100000@duckman.distro.conectiva>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Christian Smith <csmith@micromuse.com>, Daniel Phillips <phillips@bonn-fries.net>, Joseph A Knapka <jknapka@earthlink.net>, "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 7 May 2002, William Lee Irwin III wrote:
>> Procedural interfaces to pagetable manipulations are largely what
>> the BSD pmap and SVR4 HAT layers consisted of, no?

On Tue, May 07, 2002 at 04:49:08PM -0300, Rik van Riel wrote:
> Indeed, but there is a difference between:
> 1) we need to get a proper interface
> and
> 2) we should have 2 sets of data structures, one shadowing the other
> I like (1), but have my doubts about (2) ...

If such schemes were implemented and (2) occurred, IMHO it would be
pessimal and should not be merged.

Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
