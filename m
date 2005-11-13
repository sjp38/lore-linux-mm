Date: Sun, 13 Nov 2005 15:09:06 +0000
From: Pavel Machek <pavel@suse.cz>
Subject: Re: [RFC] sys_punchhole()
Message-ID: <20051113150906.GA2193@spitz.ucw.cz>
References: <1131664994.25354.36.camel@localhost.localdomain> <20051110153254.5dde61c5.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20051110153254.5dde61c5.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Badari Pulavarty <pbadari@us.ibm.com>, andrea@suse.de, hugh@veritas.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi!

> > We discussed this in madvise(REMOVE) thread - to add support 
> > for sys_punchhole(fd, offset, len) to complete the functionality
> > (in the future).
> > 
> > http://marc.theaimsgroup.com/?l=linux-mm&m=113036713810002&w=2
> > 
> > What I am wondering is, should I invest time now to do it ?
> 
> I haven't even heard anyone mention a need for this in the past 1-2 years.

Some database people wanted it maybe month ago. It was replaced by some 
madvise hack...

-- 
64 bytes from 195.113.31.123: icmp_seq=28 ttl=51 time=448769.1 ms         

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
