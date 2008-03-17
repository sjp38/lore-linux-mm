Date: Mon, 17 Mar 2008 21:44:27 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [2/18] Add basic support for more than one hstate in hugetlbfs
Message-ID: <20080317204427.GA10846@one.firstfloor.org>
References: <20080317258.659191058@firstfloor.org> <20080317015815.D43991B41E0@basil.firstfloor.org> <1205785364.10849.74.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1205785364.10849.74.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, pj@sgi.com, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

> PowerPC will have a 64KB huge page.  Granted, you do fix this in a later
> patch, so as long as the whole series goes together this shouldn't cause
> a problem.

No the later patch only supports GB and MB. If you want KB
you have to do it yourself.

But my patch just keeps the KB support as it was before.
> 
> Since mask can always be derived from order, is there a reason we don't

If there was a reason I forgot it. Doesn't really matter much either
way.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
