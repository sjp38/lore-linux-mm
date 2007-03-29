Message-ID: <460B47BE.5080502@yahoo.com.au>
Date: Thu, 29 Mar 2007 14:59:42 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch resend v4] update ctime and mtime for mmaped write
References: <20070328095014.20945.qmail@science.horizon.com>
In-Reply-To: <20070328095014.20945.qmail@science.horizon.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux@horizon.com
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, miklos@szeredi.hu
List-ID: <linux-mm.kvack.org>

linux@horizon.com wrote:
>>But if you didn't notice until now, then the current implementation
>>must be pretty reasonable for you use as well.
> 
> 
> Oh, I definitely noticed.  As soon as I tried to port my application
> to 2.6, it broke - as evidenced by my complaints last year.  The
> current solution is simple - since it's running on dedicated boxes,
> leave them on 2.4.

Well I didn't know that was a change in behaviour vs 2.4 (or maybe I
did and forgot). That was probably a bit silly, unless there was a
good reason for it.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
