Message-ID: <43CBD1C4.5020002@FreeBSD.org>
Date: Mon, 16 Jan 2006 09:03:00 -0800
From: Suleiman Souhlal <ssouhlal@FreeBSD.org>
MIME-Version: 1.0
Subject: Re: differences between MADV_FREE and MADV_DONTNEED
References: <20051101000509.GA11847@ccure.user-mode-linux.org> <1130894101.24503.64.camel@localhost.localdomain> <20051102014321.GG24051@opteron.random> <1130947957.24503.70.camel@localhost.localdomain> <20051111162511.57ee1af3.akpm@osdl.org> <1131755660.25354.81.camel@localhost.localdomain> <20051111174309.5d544de4.akpm@osdl.org> <43757263.2030401@us.ibm.com> <20060116130649.GE15897@opteron.random> <43CBC37F.60002@FreeBSD.org> <20060116162808.GG15897@opteron.random>
In-Reply-To: <20060116162808.GG15897@opteron.random>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Badari Pulavarty <pbadari@us.ibm.com>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, hugh@veritas.com, dvhltc@us.ibm.com, linux-mm@kvack.org, blaisorblade@yahoo.it, jdike@addtoit.com
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:

> We can also use it for the same purpose, we could add the pages to
> swapcache mark them dirty and zap the ptes _after_ that.

Wouldn't that cause the pages to get swapped out immediately?
If so, I don't think this would be the best approach: It would be better 
  to just move the pages to the inactive list, if they aren't there 
already, so that they get swapped out only when they really need to be.

-- Suleiman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
