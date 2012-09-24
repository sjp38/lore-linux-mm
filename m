Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 34FF86B002B
	for <linux-mm@kvack.org>; Mon, 24 Sep 2012 08:29:44 -0400 (EDT)
Date: Mon, 24 Sep 2012 20:29:00 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: divide error: bdi_dirty_limit+0x5a/0x9e
Message-ID: <20120924122900.GA28627@localhost>
References: <20120924102324.GA22303@aftab.osrc.amd.com>
 <50603829.9050904@linux.vnet.ibm.com>
 <20120924110554.GC22303@aftab.osrc.amd.com>
 <50604047.7000908@linux.vnet.ibm.com>
 <20120924113447.GA25182@localhost>
 <20120924122053.GD22303@aftab.osrc.amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120924122053.GD22303@aftab.osrc.amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@amd64.org>
Cc: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, Conny Seidel <conny.seidel@amd.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Mon, Sep 24, 2012 at 02:20:53PM +0200, Borislav Petkov wrote:
> On Mon, Sep 24, 2012 at 07:34:47PM +0800, Fengguang Wu wrote:
> > Will you test such a line? At least the generic do_div() only uses the
> > lower 32bits for division.
> > 
> >         WARN_ON(!(den & 0xffffffff));
> 
> But, but, the asm output says:
> 
>   28:   48 89 c8                mov    %rcx,%rax
>   2b:*  48 f7 f7                div    %rdi     <-- trapping instruction
>   2e:   31 d2                   xor    %edx,%edx
> 
> and this version of DIV does an unsigned division of RDX:RAX by the
> contents of a *64-bit register* ... in our case %rdi.
> 
> Srivatsa's oops  shows the same:
> 
>   28:   48 89 f0                mov    %rsi,%rax
>   2b:*  48 f7 f7                div    %rdi     <-- trapping instruction
>   2e:   41 8b 94 24 74 02 00    mov    0x274(%r12),%edx
> 
> Right?

Right, that's why I said "at least". As for x86, I'm as clueless as you..

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
