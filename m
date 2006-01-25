Date: Wed, 25 Jan 2006 14:13:56 +0000
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: nommu use compound pages?
Message-ID: <20060125141356.GA2133@infradead.org>
References: <20060125091509.GB32653@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060125091509.GB32653@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: David Howells <dhowells@redhat.com>, Andrew Morton <akpm@osdl.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 25, 2006 at 10:15:09AM +0100, Nick Piggin wrote:
> Hi,
> 
> This topic came up about a year ago but I couldn't work out why it never
> happened. Possibly because compound pages wheren't always enabled.
> 
> Now that they are, can we have another shot? It would be great to
> unify all this stuff finally. I must admit I'm not too familiar with
> the nommu code, but I couldn't find a fundamental problem from the
> archives.

I still don't know why nommu uses these at all.  Cc'in the uclinux maintainer
and list owuld be helpfull if you'd like to find out though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
