Subject: Re: [Lhms-devel] [RFC] buddy allocator without bitmap  [2/4]
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <412E6CC3.8060908@jp.fujitsu.com>
References: <412DD1AA.8080408@jp.fujitsu.com>
	 <1093535402.2984.11.camel@nighthawk>  <412E6CC3.8060908@jp.fujitsu.com>
Content-Type: text/plain
Message-Id: <1093561869.2984.360.camel@nighthawk>
Mime-Version: 1.0
Date: Thu, 26 Aug 2004 16:11:09 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lhms <lhms-devel@lists.sourceforge.net>, William Lee Irwin III <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2004-08-26 at 16:05, Hiroyuki KAMEZAWA wrote:
> I understand using these macros cleans up codes as I used them in my previous
> version.
> 
> In the previous version, I used SetPagePrivate()/ClearPagePrivate()/PagePrivate().
> But these are "atomic" operation and looks very slow.
> This is why I doesn't used these macros in this version.
> 
> My previous version, which used set_bit/test_bit/clear_bit, shows very bad performance
> on my test, and I replaced it.
> 
> If I made a mistake on measuring the performance and set_bit/test_bit/clear_bit
> is faster than what I think, I'd like to replace them.

Sorry, I misread your comment:

/* Atomic operation is needless here */

I read "needless" as "needed".  Would it make any more sense to you to
say "already have lock, don't need atomic ops", instead?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
