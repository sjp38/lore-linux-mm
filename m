Date: Mon, 21 Oct 2002 14:16:28 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: ZONE_NORMAL exhaustion (dcache slab)
Message-ID: <308170000.1035234988@flay>
In-Reply-To: <3DB46DFA.DFEB2907@digeo.com>
References: <302190000.1035232837@flay> <3DB46DFA.DFEB2907@digeo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>> My big NUMA box went OOM over the weekend and started killing things
>> for no good reason (2.5.43-mm2). Probably running some background
>> updatedb for locate thing, not doing any real work.
>> 
>> meminfo:
>> 
> 
> Looks like a plain dentry leak to me.  Very weird.
> 
> Did the machine recover and run normally?

Nope, kept OOMing and killing everything .
 
> Was it possible to force the dcache to shrink? (a cat /dev/hda1
> would do that nicely)

Well, I didn't try that, but even looking at man pages got oom killed,
so I guess not ... were you looking at the cat /dev/hda1 to fill pagecache
or something? I have 16Gb of highmem (pretty much all ununsed) so 
presumably that'd fill the highmem first (pagecache?)

> Is it reproducible?

Will try again. Presumably "find /" should do it? ;-)

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
