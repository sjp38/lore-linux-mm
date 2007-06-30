Date: Sat, 30 Jun 2007 11:09:22 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: vm/fs meetup in september?
Message-ID: <20070630100922.GA23495@infradead.org>
References: <20070624042345.GB20033@wotan.suse.de> <6934efce0706251708h7ab8d7dal6682def601a82073@mail.gmail.com> <20070626060528.GA15134@infradead.org> <6934efce0706261007x5e402eebvc528d2d39abd03a3@mail.gmail.com> <20070630093243.GD22354@infradead.org> <87bqexiwu3.wl%peter@chubb.wattle.id.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87bqexiwu3.wl%peter@chubb.wattle.id.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: peter@chubb.wattle.id.au
Cc: Christoph Hellwig <hch@infradead.org>, Jared Hulbert <jaredeh@gmail.com>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, Jun 30, 2007 at 06:02:44AM -0400, peter@chubb.wattle.id.au wrote:
> You need either a block translation layer, or a (swap) filesystem that
> understands flash peculiarities in order to make such a thing work.
> The standard Linux swap format will not work.

Yes, it basically needs an ftl.  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
