Date: Fri, 5 Jan 2001 22:26:24 +0100
From: Christoph Hellwig <hch@caldera.de>
Subject: Re: MM/VM todo list
Message-ID: <20010105222624.A11770@caldera.de>
References: <20010105221326.A10112@caldera.de> <Pine.LNX.4.21.0101051918550.1295-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.21.0101051918550.1295-100000@duckman.distro.conectiva>; from riel@conectiva.com.br on Fri, Jan 05, 2001 at 07:20:24PM -0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Jan 05, 2001 at 07:20:24PM -0200, Rik van Riel wrote:
> > >   * VM: Use kiobuf IO in VM instead buffer_head IO. 
> > 
> > I'd vote for killing both bufer_head and kiobuf from VM.
> > Lokk at my pageio patch - VM doesn't know about the use of kiobufs
> > in the filesystem IO...
> 
> Could be interesting ... but is it generalised enough to
> also work with eg. network IO ?

No other then filesystem IO (page/buffercache) is actively tied to the VM,
so there should be no problems.

	Christoph

-- 
Whip me.  Beat me.  Make me maintain AIX.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
