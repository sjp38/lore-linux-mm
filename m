Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4NKhGAo014498
	for <linux-mm@kvack.org>; Fri, 23 May 2008 16:43:16 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4NKhGx7143672
	for <linux-mm@kvack.org>; Fri, 23 May 2008 16:43:16 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4NKhFAW007041
	for <linux-mm@kvack.org>; Fri, 23 May 2008 16:43:16 -0400
Date: Fri, 23 May 2008 13:43:13 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 17/18] x86: add hugepagesz option on 64-bit
Message-ID: <20080523204313.GF23924@us.ibm.com>
References: <20080423015302.745723000@nick.local0.net> <20080423015431.462123000@nick.local0.net> <20080430204841.GD6903@us.ibm.com> <20080523054133.GO13071@wotan.suse.de> <20080523104327.GG31727@one.firstfloor.org> <20080523123436.GA25172@wotan.suse.de> <20080523142956.GI31727@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080523142956.GI31727@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Nick Piggin <npiggin@suse.de>, akpm@linux-foundation.org, linux-mm@kvack.org, kniht@linux.vnet.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On 23.05.2008 [16:29:56 +0200], Andi Kleen wrote:
> > Oh, maybe you misunderstand what I meant: I think the multiple
> > hugepages stuff is nice, and definitely should go in. But I think
> > that if there is any more disagreement over the userspace APIs, then
> > we should just merge
> 
> What disagreement was there? (sorry didn't notice it)

Whether or not this information should be presented in /proc at all. And
I would prefer to call it a "discussion" not a disagreement :)

> AFAIK the patchkit does not change any user interfaces except for
> adding a few numbers to one line of /proc/meminfo and a few other
> sysctls which seems hardly like a big change (and calling that a "API"
> would be making a mountain out of a molehill)

I'm somewhat ambivalent about the meminfo changes, although I do not
think they are necessary with a sysfs interface, but I really don't like
the idea of the multi-valued sysctl. Especially if, as we are talking
about, all hugepage sizes will be available in-kernel at all times. That
means any pool manipulations on modern power hardware will require
echo'ing three values, even if only one or two are to be modified (and
the third (16G) can't be changed anyways!) Then the ordering also
becomes an issue. As I pointed out to Nick, while on x86_64, 2M would
come first as the legacy size, it's actually due to a subtle ordering
constraint, which is not guaranteed to be the case on other
architectures (and was not on power with 64k hugepages, in my testing).

The sysfs patch has been written and is really just waiting on a repost
to post it again (it was discussed in a different thread with Greg and
others). I didn't get final confirmation from Greg that I had done
things correctly, but I'm sure he'll yell when I post the version to
merge.

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
