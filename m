Subject: Re: MM patches against 2.5.31
From: Steven Cole <elenstev@mesatop.com>
In-Reply-To: <2631076918.1030007179@[10.10.2.3]>
References: <1030031958.14756.479.camel@spc9.esa.lanl.gov>
	<2631076918.1030007179@[10.10.2.3]>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 22 Aug 2002 13:45:52 -0600
Message-Id: <1030045552.3954.10.camel@spc9.esa.lanl.gov>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Cc: Andrew Morton <akpm@zip.com.au>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2002-08-22 at 10:06, Martin J. Bligh wrote:
> > kjournald: page allocation failure. order:0, mode:0x0
> 
> I've seen this before, but am curious how we ever passed
> a gfpmask (aka mode) of 0 to __alloc_pages? Can't see anywhere
> that does this?
> 
> Thanks,
> 
> M.

I ran dbench 1..128 on 2.5.31-mm1 several more times with nothing
unusual happening, and then got this from pdflush with dbench 96.

pdflush: page allocation failure. order:0, mode:0x0

FWIW, this 2.5.31-mm1 kernel is SMP, HIGHMEM4G, no PREEMPT.

Steven

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
