Date: Thu, 22 Jan 2004 12:00:29 +0000
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: 2.6.2-rc1-mm1
Message-ID: <20040122120029.A9758@infradead.org>
References: <20040122013501.2251e65e.akpm@osdl.org> <20040122110731.A9319@infradead.org> <200401221217.i0MCHmeS001953@ccure.user-mode-linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200401221217.i0MCHmeS001953@ccure.user-mode-linux.org>; from jdike@addtoit.com on Thu, Jan 22, 2004 at 07:17:48AM -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Dike <jdike@addtoit.com>
Cc: Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 22, 2004 at 07:17:48AM -0500, Jeff Dike wrote:
> hch@infradead.org said:
> > And this one brings in perfectly broken 2.4 block drivers.
> 
> Can you be specific?

Try compiling the cow driver.  Or look at the utter devfs mess in ubd.
In fact I wonder why the mail on that devfs abuse that I sent to uml-devel
about half a year ago is still unanswered.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
