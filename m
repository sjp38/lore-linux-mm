Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 1513F6B004D
	for <linux-mm@kvack.org>; Fri,  9 Dec 2011 14:53:39 -0500 (EST)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: XFS causing stack overflow
References: <CAAnfqPAm559m-Bv8LkHARm7iBW5Kfs7NmjTFidmg-idhcOq4sQ@mail.gmail.com>
	<20111209115513.GA19994__23079.9863501035$1323435203$gmane$org@infradead.org>
Date: Fri, 09 Dec 2011 11:53:36 -0800
In-Reply-To: <20111209115513.GA19994__23079.9863501035$1323435203$gmane$org@infradead.org>
	(Christoph Hellwig's message of "Fri, 9 Dec 2011 06:55:13 -0500")
Message-ID: <m2aa71plmn.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: "Ryan C. England" <ryan.england@corvidtec.com>, linux-mm@kvack.org, xfs@oss.sgi.com

Christoph Hellwig <hch@infradead.org> writes:
>
> You probably have only a third of the stack actually used by XFS, the
> rest is from NFSD/writeback code and page reclaim.  I don't think any
> of this is easily fixable in a 2.6.32 codebase.  Current mainline 3.2-rc
> now has the I/O-less balance dirty pages which will basically split the
> stack footprint in half, but it's an invasive change to the writeback
> code that isn't easily backportable.

An easy fix would be 16k stacks. Don't think they're that difficult
to do, but would need a special binary.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
