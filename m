Date: Fri, 5 Jan 2001 19:27:38 -0200 (BRDT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: MM/VM todo list
In-Reply-To: <20010105222624.A11770@caldera.de>
Message-ID: <Pine.LNX.4.21.0101051927040.1295-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@caldera.de>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 5 Jan 2001, Christoph Hellwig wrote:
> On Fri, Jan 05, 2001 at 07:20:24PM -0200, Rik van Riel wrote:
> > > >   * VM: Use kiobuf IO in VM instead buffer_head IO. 
> > > 
> > > I'd vote for killing both bufer_head and kiobuf from VM.
> > > Lokk at my pageio patch - VM doesn't know about the use of kiobufs
> > > in the filesystem IO...
> > 
> > Could be interesting ... but is it generalised enough to
> > also work with eg. network IO ?
> 
> No other then filesystem IO (page/buffercache) is actively tied
> to the VM, so there should be no problems.

Not right now, no. But if you know what is possible
(and planned) with the kiobuf layer, you should think
twice about this idea...

regards,

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to loose...

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com.br/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
