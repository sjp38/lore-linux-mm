From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] use local_t for page statistics
Date: Sat, 7 Jan 2006 05:03:13 +0100
References: <20060106215332.GH8979@kvack.org> <200601070425.24810.ak@suse.de> <43BF3A06.10502@yahoo.com.au>
In-Reply-To: <43BF3A06.10502@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200601070503.14336.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@osdl.org>, Benjamin LaHaise <bcrl@kvack.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Saturday 07 January 2006 04:48, Nick Piggin wrote:

> 
> At a 3x cache footprint cost? (and probably more than 3x for icache, though
> I haven't checked) And I think hardware trends are against us. (Also, does
> it have race issues with nested interrupts that Andrew noticed?)

Well the alternative would be to just let them turn off interrupts.
If that's cheap for them that's fine too. And would be equivalent
to what the current high level code does.

If you worry about icache footprint it can be even done out of line.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
