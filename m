Message-ID: <4317F50B.6080005@yahoo.com.au>
Date: Fri, 02 Sep 2005 16:45:31 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: New lockless pagecache
References: <4317F071.1070403@yahoo.com.au>
In-Reply-To: <4317F071.1070403@yahoo.com.au>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:

> I think this is getting pretty stable. No guarantees of course,
> but it would be great if anyone gave it a test.
> 

Or review, I might add. While I understand such a review is
still quite difficult, this code really is far less complex
than the previous lockless pagecache patches.

(Ignore 1/7 though, which is a rollup - a broken out patchset
can be provided on request)

Nick

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
