Received: by wa-out-1112.google.com with SMTP id m33so2348407wag
        for <linux-mm@kvack.org>; Tue, 26 Jun 2007 10:07:24 -0700 (PDT)
Message-ID: <6934efce0706261007x5e402eebvc528d2d39abd03a3@mail.gmail.com>
Date: Tue, 26 Jun 2007 10:07:24 -0700
From: "Jared Hulbert" <jaredeh@gmail.com>
Subject: Re: vm/fs meetup in september?
In-Reply-To: <20070626060528.GA15134@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070624042345.GB20033@wotan.suse.de>
	 <6934efce0706251708h7ab8d7dal6682def601a82073@mail.gmail.com>
	 <20070626060528.GA15134@infradead.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>, Jared Hulbert <jaredeh@gmail.com>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 6/25/07, Christoph Hellwig <hch@infradead.org> wrote:
> On Mon, Jun 25, 2007 at 05:08:02PM -0700, Jared Hulbert wrote:
> > -memory mappable swap file (I'm not sure if this one is appropriate
> > for the proposed meeting)
>
> Please explain what this is supposed to mean.

If you have a large array of a non-volatile semi-writeable memory such
as a highspeed NOR Flash or some of the similar emerging technologies
in a system.  It would be useful to use that memory as an extension of
RAM.  One of the ways you could do that is allow pages to be swapped
out to this memory.  Once there these pages could be read directly,
but would require a COW procedure on a write access.  The reason why I
think this may be a vm/fs topic is that the hardware makes writing to
this memory efficiently a non-trivial operation that requires
management just like a filesystem.  Also it seems to me that there are
probably overlaps between this topic and the recent filemap_xip.c
discussions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
