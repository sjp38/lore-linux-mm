Date: Mon, 16 Aug 2004 15:34:53 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: use for page_state accounting fields
Message-Id: <20040816153453.756a2cd0.akpm@osdl.org>
In-Reply-To: <20040816203322.GA21796@logos.cnet>
References: <20040816192941.GB21238@logos.cnet>
	<20040816143149.510a2f90.akpm@osdl.org>
	<20040816203322.GA21796@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti <marcelo.tosatti@cyclades.com> wrote:
>
> > Take a peek in /proc/vmstat ;)
> 
> Doh. 
> 
> Is there any tool which reads these statistics and makes use of them? Number of 
> inactivations/activations per timeframe, etc?

Not that I am aware of.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
