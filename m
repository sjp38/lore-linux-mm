Message-ID: <45E63BF5.6040007@yahoo.com.au>
Date: Thu, 01 Mar 2007 13:35:33 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Remove page flags for software suspend
References: <Pine.LNX.4.64.0702160212150.21862@schroedinger.engr.sgi.com> <20070228101403.GA8536@elf.ucw.cz> <Pine.LNX.4.64.0702280724540.16552@schroedinger.engr.sgi.com> <200702281813.04643.rjw@sisk.pl> <Pine.LNX.4.64.0702280915030.3263@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0702280915030.3263@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, Pavel Machek <pavel@ucw.cz>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Wed, 28 Feb 2007, Rafael J. Wysocki wrote:
> 
> 
>>As I have already said for a couple of times, I think we can and I'm going to
>>do it, but right now I'm a bit busy with other things that I consider as more
>>urgent.
> 
> 
> Ummm.. There are other parties who would like to use these flags!

Lots of other parties. Let's make sure that no more backdoor page flags get
allocated without going through the linux-mm list to work out whether we
really need it or can live without it...

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
