Date: Mon, 4 Oct 2004 14:32:58 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [RFC] memory defragmentation to satisfy high order allocations
Message-ID: <20041004173258.GN16374@logos.cnet>
References: <20041001182221.GA3191@logos.cnet> <4160B7A8.7010607@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4160B7A8.7010607@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, akpm@osdl.org, Nick Piggin <piggin@cyberone.com.au>, arjanv@redhat.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Yeap that is a nice optimization, thanks Hiroyuki.

On Mon, Oct 04, 2004 at 11:38:32AM +0900, Hiroyuki KAMEZAWA wrote:
> 
> how about inserting this if-sentense ?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
