Date: Mon, 17 Sep 2007 02:13:49 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Userspace tools  (was Re: [PATCH][RESEND] maps:
 PSS(proportional set size) accounting in smaps)
Message-Id: <20070917021349.e497d12f.akpm@linux-foundation.org>
In-Reply-To: <20070917090057.GA2083@infradead.org>
References: <389996856.30386@ustc.edu.cn>
	<20070916235120.713c6102.akpm@linux-foundation.org>
	<46EE2802.1000007@linux.vnet.ibm.com>
	<20070917090057.GA2083@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Fengguang Wu <wfg@mail.ustc.edu.cn>, John Berthels <jjberthels@gmail.com>, Denys Vlasenko <vda.linux@googlemail.com>, Matt Mackall <mpm@selenic.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 17 Sep 2007 10:00:57 +0100 Christoph Hellwig <hch@infradead.org> wrote:

> On Mon, Sep 17, 2007 at 12:38:50PM +0530, Balbir Singh wrote:
> > Andrew Morton wrote:
> > > On Mon, 17 Sep 2007 10:40:54 +0800 Fengguang Wu <wfg@mail.ustc.edu.cn> wrote:
> > > 
> > >> Matt Mackall's pagemap/kpagemap and John Berthels's exmap can also do the job.
> > >> They are comprehensive tools. But for PSS, let's do it in the simple way. 
> > > 
> > > right.  I'm rather reluctant to merge anything which could have been done from
> > > userspace via the maps2 interfaces.
> > > 
> > > See, this is why I think the kernel needs a ./userspace-tools/ directory.  If
> > > we had that, you might have implemented this as a little proglet which parses
> > > the maps2 files.  But we don't have that, so you ended up doing it in-kernel.
> > 
> > Andrew, I second the userspace-tools idea. I would also add an FAQ in
> > that directory, explaining what problem each tool solves. I think your
> > page cache control program would be a great example of something to put
> > in there.
> 
> It's called the util-linux package.

That's the theory.  I'd be interested in seeing someone test it out: submit
something and see if/when it goes in and gets redistributed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
