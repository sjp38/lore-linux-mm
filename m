Date: Mon, 21 Oct 2002 14:33:35 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: ZONE_NORMAL exhaustion (dcache slab)
Message-ID: <309670000.1035236015@flay>
In-Reply-To: <3DB472B6.BC5B8924@digeo.com>
References: <3DB46DFA.DFEB2907@digeo.com> <308170000.1035234988@flay> <3DB472B6.BC5B8924@digeo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>> Nope, kept OOMing and killing everything .
> 
> Something broke.

Even I worked that out ;-) 

> Blockdevices only use ZONE_NORMAL for their pagecache.  That cat will
> selectively put pressure on the normal zone (and DMA zone, of course).

Ah, I recall that now. That's fundamentally screwed.
  
>> Will try again. Presumably "find /" should do it? ;-)
> 
> You must have a lot of files.

Nothing too ridiculous. Will try find on a small subset repeatedly and see if
it keeps growing first - maybe that'll show a leak.
 
Thanks,

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
