Date: Mon, 28 Mar 2005 16:51:43 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [RFC][PATCH] tunable zone watermarks
Message-ID: <20050328195143.GJ29310@logos.cnet>
References: <2c1942a70503272243c351eee@mail.gmail.com> <160420000.1112038232@flay>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <160420000.1112038232@flay>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Levent Serinol <lserinol@gmail.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Martin,

On Mon, Mar 28, 2005 at 11:30:32AM -0800, Martin J. Bligh wrote:
> What situations do you want to tune them in? Would be nicer to do this
> automagically ...

We do it automagically right now. What do you mean?

It is useful for testing purpose - but then you need an understanding of
MM internals to make good use of it.

The only tweak available now is lowmem_reserve.

I'm sure there are loads where the default watermark values are 
not optimal.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
