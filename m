Date: Wed, 19 Jan 2005 13:39:53 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: BUG in shared_policy_replace() ?
Message-Id: <20050119133953.667630f5.akpm@osdl.org>
In-Reply-To: <20050119192955.GC26170@wotan.suse.de>
References: <Pine.LNX.4.44.0501191221400.4795-100000@localhost.localdomain>
	<41EE9991.6090606@mvista.com>
	<20050119174506.GH7445@wotan.suse.de>
	<41EEA575.9040007@mvista.com>
	<20050119183430.GK7445@wotan.suse.de>
	<41EEAE04.3050505@mvista.com>
	<20050119190927.GM7445@wotan.suse.de>
	<41EEB440.8010108@mvista.com>
	<20050119192955.GC26170@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: stevel@mvista.com, hugh@veritas.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, andrea@suse.de
List-ID: <linux-mm.kvack.org>

Andi Kleen <ak@suse.de> wrote:
>
>  > -				new2 = NULL;
> 
>  Ah, I agree. Yes, it looks like a merging error when merging
>  with Hugh's changes. Thanks for catching this.
> 
>  The line should not be removed. Andrew should I submit a new patch or can 
>  you just fix it up?

I'll fix it up, thanks.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
