Date: Wed, 19 Jan 2005 19:34:30 +0100
From: Andi Kleen <ak@suse.de>
Subject: Re: BUG in shared_policy_replace() ?
Message-ID: <20050119183430.GK7445@wotan.suse.de>
References: <Pine.LNX.4.44.0501191221400.4795-100000@localhost.localdomain> <41EE9991.6090606@mvista.com> <20050119174506.GH7445@wotan.suse.de> <41EEA575.9040007@mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <41EEA575.9040007@mvista.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Steve Longerbeam <stevel@mvista.com>
Cc: Andi Kleen <ak@suse.de>, Hugh Dickins <hugh@veritas.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> yeah, 2.6.10 makes sense to me too. But I'm working in -mm2, and
> the new2 = NULL line is missing, hence my initial confusion. Trivial
> patch to -mm2 attached. Just want to make sure it has been, or will be,
> put back in.

That sounds weird. Can you figure out which patch in mm removes it?

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
