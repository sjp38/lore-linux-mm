Date: Fri, 04 Apr 2003 20:52:02 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: objrmap and vmtruncate
Message-ID: <9320000.1049518322@[10.10.2.4]>
In-Reply-To: <20030405024414.GP16293@dualathlon.random>
References: <20030404163154.77f19d9e.akpm@digeo.com> <12880000.1049508832@flay> <20030405024414.GP16293@dualathlon.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Andrew Morton <akpm@digeo.com>, mingo@elte.hu, hugh@veritas.com, dmccr@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> I'm not convinced that we can't do something with nonlinear mappings for
>> this ... we just need to keep a list of linear areas within the nonlinear
>> vmas, and use that to do the objrmap stuff with. Dave and I talked about
>> this yesterday ... we both had different terminology, but I think the
>> same underlying fundamental concept ... I was calling them "sub-vmas"
>> for each linear region within the nonlinear space. 
> 
> that's wasted memory IMHO, if you need nonlinear, you don't want to
> waste further metadata, you only want to pin pages in the pagetables,
> the 'window' over the pagecache (incidentally shm)

Hold on a minute ... don't the rmap chains (which this would be replacing)
waste rather more space than this anyway? I'd rather have it per linear
area than per-page ... think of it as "shared rmap pte chains with offsets"
if you like ;-)

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
