Date: Thu, 27 Oct 2005 16:16:02 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [RFC] madvise(MADV_TRUNCATE)
Message-Id: <20051027161602.38a4051b.akpm@osdl.org>
In-Reply-To: <1130454352.23729.134.camel@localhost.localdomain>
References: <1130366995.23729.38.camel@localhost.localdomain>
	<200510271038.52277.ak@suse.de>
	<20051027131725.GI5091@opteron.random>
	<1130425212.23729.55.camel@localhost.localdomain>
	<20051027151123.GO5091@opteron.random>
	<20051027112054.10e945ae.akpm@osdl.org>
	<20051027200434.GT5091@opteron.random>
	<20051027135058.2f72e706.akpm@osdl.org>
	<20051027213721.GX5091@opteron.random>
	<20051027152340.5e3ae2c6.akpm@osdl.org>
	<1130454352.23729.134.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: andrea@suse.de, ak@suse.de, hugh@veritas.com, jdike@addtoit.com, dvhltc@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Badari Pulavarty <pbadari@us.ibm.com> wrote:
>
> On Thu, 2005-10-27 at 15:23 -0700, Andrew Morton wrote:
> 
> > 
> > hm.   Tossing ideas out here:
> > 
> > - Implement the internal infrastructure as you have it
> > 
> > - View it as a filesystem operation which has MM side-effects.
> > 
> > - Initially access it via sys_ipc()  (or madvise, I guess.  Both are a bit odd)
> > 
> > - Later access it via sys_[hole]punch()
> 
> Thats exactly what my patch provides. Do you really want to see this
> through sys_ipc() or shmctl() ? I personally think madvise() or
> sys_holepunch are the closest (since they work on a range).

Well I do think mdavise() is an unnatural interface to what is mainly a
filesystem operation.

It's just that this initial requirement is actually a need for the
operation's MM side-effects, so we're incorrectly thinking of it as an MM
operation.  I think.

> What else I need to do to make it more palatable ?

Can we do sys_fholepunch(int fd, loff_t offset, loff_t length)?  That
requires that your applications know both the fd and the file offset.  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
