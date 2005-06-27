Message-ID: <42BFBF5B.7080301@cisco.com>
Date: Mon, 27 Jun 2005 18:56:59 +1000
From: Lincoln Dale <ltd@cisco.com>
MIME-Version: 1.0
Subject: Re: [rfc] lockless pagecache
References: <42BF9CD1.2030102@yahoo.com.au> <20050627004624.53f0415e.akpm@osdl.org> <42BFB287.5060104@yahoo.com.au>
In-Reply-To: <42BFB287.5060104@yahoo.com.au>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
[..]

> However I think for Oracle and others that use shared memory like
> this, they are probably not doing linear access, so that would be a
> net loss. I'm not completely sure (I don't have access to real loads
> at the moment), but I would have thought those guys would have looked
> into fault ahead if it were a possibility.

i thought those guys used O_DIRECT - in which case, wouldn't the page 
cache not be used?


cheers,

lincoln.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
