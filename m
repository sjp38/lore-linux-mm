Date: Tue, 7 May 2002 12:47:50 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Why *not* rmap, anyway?
Message-ID: <20020507194750.GV15756@holomorphy.com>
References: <Pine.LNX.4.33.0205071625570.1579-100000@erol> <E175Ame-0000Tb-00@starship>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <E175Ame-0000Tb-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@bonn-fries.net>
Cc: Christian Smith <csmith@micromuse.com>, Rik van Riel <riel@conectiva.com.br>, Joseph A Knapka <jknapka@earthlink.net>, "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday 07 May 2002 20:37, Christian Smith wrote:
>> - do_page_fault() is definately in the wrong place, or at least, the work 
>>   it does (it finds the generic vma of the fault. This should be generic 
>>   code.)

On Tue, May 07, 2002 at 09:37:57PM +0200, Daniel Phillips wrote:
> It's per-arch because different architectures have very different sets of
> conditions that have to be handled.  If you like, you can try to break out
> some cross-arch factors and make them into inlines or something.  That's
> cleanup work that's hard and mostly thankless.  We need more gluttons for
> punishment^W^W^W volunteers to tackle this kind of thing.

I believe I'm already signed up for this, or at least I'm putting down
code on this front.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
