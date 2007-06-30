Date: Sat, 30 Jun 2007 10:32:43 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: vm/fs meetup in september?
Message-ID: <20070630093243.GD22354@infradead.org>
References: <20070624042345.GB20033@wotan.suse.de> <6934efce0706251708h7ab8d7dal6682def601a82073@mail.gmail.com> <20070626060528.GA15134@infradead.org> <6934efce0706261007x5e402eebvc528d2d39abd03a3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6934efce0706261007x5e402eebvc528d2d39abd03a3@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jared Hulbert <jaredeh@gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 26, 2007 at 10:07:24AM -0700, Jared Hulbert wrote:
> If you have a large array of a non-volatile semi-writeable memory such
> as a highspeed NOR Flash or some of the similar emerging technologies
> in a system.  It would be useful to use that memory as an extension of
> RAM.  One of the ways you could do that is allow pages to be swapped
> out to this memory.  Once there these pages could be read directly,
> but would require a COW procedure on a write access.  The reason why I
> think this may be a vm/fs topic is that the hardware makes writing to
> this memory efficiently a non-trivial operation that requires
> management just like a filesystem.  Also it seems to me that there are
> probably overlaps between this topic and the recent filemap_xip.c
> discussions.

So what you mean is "swap on flash" ?  Defintively sounds like an
interesting topic, although I'm not too sure it's all that
filesystem-related.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
