Date: Thu, 22 Jan 2004 11:12:49 +0000
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: 2.6.2-rc1-mm1
Message-ID: <20040122111249.A9384@infradead.org>
References: <20040122013501.2251e65e.akpm@osdl.org> <20040122110731.A9319@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040122110731.A9319@infradead.org>; from hch@infradead.org on Thu, Jan 22, 2004 at 11:07:31AM +0000
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 22, 2004 at 11:07:31AM +0000, Christoph Hellwig wrote:
> > uml-update.patch
> >   UML update
> 
> And this one brings in perfectly broken 2.4 block drivers.  This quality
> of the UML code makes me nervous.

And we should better take the crack away from the person who wrote
mconsole_proc().

Enough for today, this code makes me sick.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
