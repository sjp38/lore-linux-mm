Date: Wed, 19 Jan 2005 18:45:06 +0100
From: Andi Kleen <ak@suse.de>
Subject: Re: BUG in shared_policy_replace() ?
Message-ID: <20050119174506.GH7445@wotan.suse.de>
References: <Pine.LNX.4.44.0501191221400.4795-100000@localhost.localdomain> <41EE9991.6090606@mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <41EE9991.6090606@mvista.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Steve Longerbeam <stevel@mvista.com>
Cc: Hugh Dickins <hugh@veritas.com>, Andi Kleen <ak@suse.de>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> got it, except that there is no "new2 = NULL;" in 2.6.10-mm2!
> 
> Looks like it was misplaced, because I do see it now in 2.6.10.

I double checked 2.6.10 and the code also looks correct me,
working as described by Hugh.

Optimistic locking can be ugly :)

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
