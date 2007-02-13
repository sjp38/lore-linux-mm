Received: by nf-out-0910.google.com with SMTP id b2so54585nfe
        for <linux-mm@kvack.org>; Mon, 12 Feb 2007 16:26:58 -0800 (PST)
Message-ID: <12c511ca0702121626u7a100671w2e684dd5845d1220@mail.gmail.com>
Date: Mon, 12 Feb 2007 16:26:57 -0800
From: "Tony Luck" <tony.luck@gmail.com>
Subject: Re: build error: allnoconfig fails on mincore/swapper_space
In-Reply-To: <45D0F2F8.7060602@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070212145040.c3aea56e.randy.dunlap@oracle.com>
	 <20070212150802.f240e94f.akpm@linux-foundation.org>
	 <45D0F2F8.7060602@oracle.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>

> > oops.  CONFIG_SWAP=n,  I assume?
>
> Yes, sorry.  Full config attached.

<metoo>Same breakage on "make allnoconfig" for ia64</metoo>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
