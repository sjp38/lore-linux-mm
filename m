Message-ID: <4850FD75.8020403@firstfloor.org>
Date: Thu, 12 Jun 2008 12:41:57 +0200
From: Andi Kleen <andi@firstfloor.org>
MIME-Version: 1.0
Subject: Re: repeatable slab corruption with LTP msgctl08
References: <20080611221324.42270ef2.akpm@linux-foundation.org>	<20080611233449.08e6eaa0.akpm@linux-foundation.org>	<20080612010200.106df621.akpm@linux-foundation.org>	<20080612011537.6146c41d.akpm@linux-foundation.org>	<87mylrnj84.fsf@basil.nowhere.org> <20080612032442.930e62e4.akpm@linux-foundation.org>
In-Reply-To: <20080612032442.930e62e4.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nadia Derbey <Nadia.Derbey@bull.net>, Manfred Spraul <manfred@colorfullife.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

> 
> But it hasn't crashed after 57 minutes.
> 
> I don't think that is how we should fix this bug ;)

This means it doesn't corrupt other slabs. Maybe only its own?

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
