Date: Sat, 28 Dec 2002 17:59:30 -0600
From: Dave McCracken <dmccr@us.ibm.com>
Subject: Re: handling pte_chain_alloc() failures
Message-ID: <23300000.1041119970@[10.1.1.5]>
In-Reply-To: <3E0CEA3F.35B3044@digeo.com>
References: <3E0CEA3F.35B3044@digeo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--On Friday, December 27, 2002 16:03:11 -0800 Andrew Morton
<akpm@digeo.com> wrote:

> Dave, could I ask you to check the locking changes carefully?  Some
> of them are fairly nasty.  Thanks.

The only thing I specifically see is related to the pte_page_lock.  In
places where ptepage is derived from *pmd, the contents of *pmd can change
if another thread unshares that pte page on a fault.  There should be a
line like:

	ptepage = pmd_page(*pmd);

in the places where it reacquires the pte_page_lock.

I'll study it some more, but that stands out.

Dave McCracken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
