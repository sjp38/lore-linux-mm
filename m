Message-ID: <45E8495A.4080501@shadowen.org>
Date: Fri, 02 Mar 2007 15:57:14 +0000
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: [PATCH 2/5] lumpy: isolate_lru_pages wants to specifically take
 active or inactive pages
References: <exportbomb.1172604830@kernel> <f2cdac47f652dc10d19f6041997e85b1@kernel> <Pine.LNX.4.64.0702281015340.21257@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0702281015340.21257@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Tue, 27 Feb 2007, Andy Whitcroft wrote:
> 
>> The caller of isolate_lru_pages specifically knows whether it wants
>> to take either inactive or active pages.  Currently we take the
>> state of the LRU page at hand and use that to scan for matching
>> pages in the order sized block.  If that page is transiting we
>> can scan for the wrong type.  The caller knows what they want and
>> should be telling us.  Pass in the required active/inactive state
>> and match against that.
> 
> The page cannot be transiting since we hold the lru lock?

As you say it should be gated by lru_lock and we should not expect to
see pages with the wrong type on the list.  I would swear that I was
seeing pages on the wrong list there for a bit in testing and mistakenly
thought they were in transition.  A quick review at least says thats
false.  So I'll reinstate the BUG() and retest to see if I am smoking
crack or there is a bigger bug out there.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
