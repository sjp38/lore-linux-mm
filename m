Date: Fri, 5 Jan 2001 22:34:59 +0100
From: Christoph Hellwig <hch@caldera.de>
Subject: Re: MM/VM todo list
Message-ID: <20010105223459.A12653@caldera.de>
References: <20010105222624.A11770@caldera.de> <Pine.LNX.4.21.0101051927040.1295-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.21.0101051927040.1295-100000@duckman.distro.conectiva>; from riel@conectiva.com.br on Fri, Jan 05, 2001 at 07:27:38PM -0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Jan 05, 2001 at 07:27:38PM -0200, Rik van Riel wrote:
> > No other then filesystem IO (page/buffercache) is actively tied
> > to the VM, so there should be no problems.
> 
> Not right now, no. But if you know what is possible
> (and planned) with the kiobuf layer, you should think
> twice about this idea...

I don't think so.  The only place were IO actively interferes with
the VM is of the 'write this out when memory gets low' type thing,
and you don't really want this outside filesystems/blockdevices.

There are some VM tricks that are usefull for IO (COW, map_user_kiobuf),
but these operate always on pages (maybe containered by kiobufs, but that
should be of minor interest for the VM).

	Christoph

-- 
Whip me.  Beat me.  Make me maintain AIX.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
