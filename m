Date: Tue, 1 May 2001 13:14:17 -0400 (EDT)
From: Alexander Viro <viro@math.psu.edu>
Subject: Re: About reading /proc/*/mem
In-Reply-To: <3AEEEC48.80709@link.com>
Message-ID: <Pine.GSO.4.21.0105011311060.9771-100000@weyl.math.psu.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Richard F Weber <rfweber@link.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Tue, 1 May 2001, Richard F Weber wrote:

> The main thing I'm looking to do is examine data that's part of a 
> real-time process.  The process's execution can't be interrupted, 
> otherwise it makes debugging it inaccurate.  The applications is 
> certainly not looking to see every line of code get executed, but rather 
> have a real-time monitor of a symbol as it gets modified.  Now 
> viewing/selecting the symbol is done through a combination of nm's & a 
> console based util (hopefully GTK Based in the future).  Other 
> applications include recording this data to disk for later playback & 
> analysis.
> 
> Now the next logical step would be to create a debug module in the RT 
> system itself that dumps out the values we care about.  The problem with 
> this is we are looking at a lot of legacy code (done in fortran, C & 
> Ada) as well as tons of variables.  By peeking at the memory on the fly 
> we can dynamically decide which values are important for this run, 
> without having to record all possible data to the disk (which in itself 
> would be quite painful since disk accesses would make debugging again 
> difficult).

You want the data in each frame be taken at the same moment. Otherwise
you are going to see inconsistent data. I.e. tons of false warnings saying
that data corruption is going on when there's none.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
