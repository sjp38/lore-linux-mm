Date: Fri, 1 Oct 2004 14:00:13 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [RFC] memory defragmentation to satisfy high order allocations
Message-Id: <20041001140013.5e3afc59.akpm@osdl.org>
In-Reply-To: <20041001190430.GA4372@logos.cnet>
References: <20041001182221.GA3191@logos.cnet>
	<20041001131147.3780722b.akpm@osdl.org>
	<20041001190430.GA4372@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: linux-mm@kvack.org, piggin@cyberone.com.au, arjanv@redhat.com, linux-kernel@vger.kernel.org, haveblue@us.ibm.com
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti <marcelo.tosatti@cyclades.com> wrote:
>
> As far as I have researched, the memory moving/remapping code 
> on the hot remove patches dont work correctly. Please correct me.
> 
> And what I've seen (from the Fujitsu guys) was quite ugly IMHO.

That's a totally different patch.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
