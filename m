Date: Tue, 31 Jul 2001 22:05:41 -0400
From: Chris Mason <mason@suse.com>
Subject: Re: [RFC] using writepage to start io
Message-ID: <41340000.996631541@tiny>
In-Reply-To: <01080103011705.00303@starship>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@bonn-fries.net>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>


On Wednesday, August 01, 2001 03:01:17 AM +0200 Daniel Phillips
<phillips@bonn-fries.net> wrote:

> Hi, Chris
> 
> On Tuesday 31 July 2001 21:07, Chris Mason wrote:
>> I had to keep some of the flush_dirty_buffer calls as page_launder
>> wasn't triggering enough i/o on its own.  What I'd like to do now is
>> experiment with changing bdflush to only write pages off the inactive
>> dirty lists.
> 
> Will kupdate continue to enforce the "no dirty buffer older than 
> XX" guarantee?

Yes, kupdate still calls flush_dirty_buffers(1).  I'm curious to see how
your write early stuff interacts with it all though....

-chris


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
