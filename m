Date: Mon, 17 Mar 2008 09:15:33 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [4/18] Add basic support for more than one hstate in hugetlbfs
Message-ID: <20080317081533.GH27015@one.firstfloor.org>
References: <20080317258.659191058@firstfloor.org> <20080317015817.DE00E1B41E0@basil.firstfloor.org> <20080317030942.8465b09e.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080317030942.8465b09e.pj@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

On Mon, Mar 17, 2008 at 03:09:42AM -0500, Paul Jackson wrote:
> Andi,
> 
> Seems to me that both patches 2/18 and 4/18 are called:
> 
>   Add basic support for more than one hstate in hugetlbfs
> 
> You probably want to change this detail.

Fixed thanks. Indeed description went wrong on 4/18
2/ was the correct one.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
