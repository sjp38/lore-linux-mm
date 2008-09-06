Date: Sat, 6 Sep 2008 02:01:54 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [RESEND] x86_64: add memory hotremove config option
Message-ID: <20080906000154.GC18288@one.firstfloor.org>
References: <20080905172132.GA11692@us.ibm.com> <87ej3yv588.fsf@basil.nowhere.org> <20080905195314.GE11692@us.ibm.com> <20080905200401.GA18288@one.firstfloor.org> <20080905215452.GF11692@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080905215452.GF11692@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gary Hade <garyhade@us.ibm.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Yasunori Goto <y-goto@jp.fujitsu.com>, Badari Pulavarty <pbadari@us.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Chris McDermott <lcm@us.ibm.com>, linux-kernel@vger.kernel.org, x86@kernel.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

> I am not sure if I understand why you appear to be opposed to
> enabling the hotremove function before all the issues related

I'm quite sceptical that it can be ever made to work in a useful
way for real hardware (as opposed to an hypervisor para virtual setup
for which this interface is not the right way -- it should be done
in some specific driver instead) 

And if it cannot be made to work then it will be a false promise
to the user. They will see it and think it will work, but it will
not.

This means I don't see a real use case for this feature.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
