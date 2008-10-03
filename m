Date: Fri, 3 Oct 2008 05:44:31 -0700
From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [PATCH] x86_64: Implement personality ADDR_LIMIT_32BIT
Message-ID: <20081003054431.33e19339@infradead.org>
In-Reply-To: <20081003092550.GA8669@localhost.localdomain>
References: <1223017469-5158-1-git-send-email-kirill@shutemov.name>
	<20081003080244.GC25408@elte.hu>
	<20081003092550.GA8669@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 3 Oct 2008 12:25:52 +0300
"Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> On Fri, Oct 03, 2008 at 10:02:44AM +0200, Ingo Molnar wrote:
> > 
> > * Kirill A. Shutemov <kirill@shutemov.name> wrote:
> > 
> > > -	/* for MAP_32BIT mappings we force the legact mmap base
> > > */
> > > -	if (!test_thread_flag(TIF_IA32) && (flags & MAP_32BIT))
> > > +	/* for MAP_32BIT mappings and ADDR_LIMIT_32BIT
> > > personality we force the
> > > +	 * legact mmap base
> > > +	 */
> > 
> > please use the customary multi-line comment style:
> > 
> >   /*
> >    * Comment .....
> >    * ...... goes here:
> >    */
> > 
> > and you might use the opportunity to fix the s/legact/legacy typo
> > as well.
> 
> Ok, I'll fix it.
> 
> > 
> > but more generally, we already have ADDR_LIMIT_3GB support on x86.
> 
> Does ADDR_LIMIT_3GB really work?

if it's broken we should fix it.... not invent a new one.
Also, traditionally often personalities only start at exec() time iirc.
(but I could be wrong on that)

-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
