Subject: Re: vDSO vs. mm : problems with ppc vdso
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20060227224739.70ecfd08.akpm@osdl.org>
References: <1141105154.3767.27.camel@localhost.localdomain>
	 <20060227215416.2bfc1e18.akpm@osdl.org>
	 <1141106896.3767.34.camel@localhost.localdomain>
	 <20060227222055.4d877f16.akpm@osdl.org>
	 <1141108220.3767.43.camel@localhost.localdomain>
	 <20060227224739.70ecfd08.akpm@osdl.org>
Content-Type: text/plain
Date: Tue, 28 Feb 2006 18:36:45 +1100
Message-Id: <1141112205.3767.47.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, hugh@veritas.com, paulus@samba.org, nickpiggin@yahoo.com.au, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

On Mon, 2006-02-27 at 22:47 -0800, Andrew Morton wrote:
> Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:
> >
> > > > I'll send the patch as a reply to this message.
> >  > 
> >  > Please copy linux-arch.
> > 
> >  Did that.
> 
> You did not, you meanie.

I did :) Under the title 


[PATCH] Add mm->task_size and fix
powerpc vdso
Check the CC list :)

> Hugh's the man - he loves that stuff.

Ok.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
