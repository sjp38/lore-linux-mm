Date: Fri, 18 Apr 2008 20:32:39 +1000 (EST)
From: James Morris <jmorris@namei.org>
Subject: Re: 2.6.25-mm1: not looking good
In-Reply-To: <20080418072457.GB18044@elte.hu>
Message-ID: <Xine.LNX.4.64.0804182029110.5998@us.intercode.com.au>
References: <20080417160331.b4729f0c.akpm@linux-foundation.org>
 <84144f020804172340l79f9c815u42e4dad69dada299@mail.gmail.com>
 <20080418072457.GB18044@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Thomas Gleixner <tglx@linutronix.de>, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Stephen Smalley <sds@tycho.nsa.gov>, Paul Moore <paul.moore@hp.com>
List-ID: <linux-mm.kvack.org>

On Fri, 18 Apr 2008, Ingo Molnar wrote:

> 
> * Pekka Enberg <penberg@cs.helsinki.fi> wrote:
> 
> > Andrew, you don't seem to have slab debugging enabled:
> > 
> > # CONFIG_DEBUG_SLAB is not set
> > 
> > And quite frankly, the oops looks unlikely to be a slab bug but rather 
> > a plain old slab corruption cause by the callers...
> 
> hm, there's sel_netnode_free() in the stackframe - that's from 
> security/selinux/netnode.c. Andrew, any recent changes in that area?

I've reverted the -mm only change to that file in 

git://git.kernel.org/pub/scm/linux/kernel/git/jmorris/selinux-2.6.git#for-akpm


commit f777964ad75cf4a119d911d12e81948d2402677f
Author: James Morris <jmorris@namei.org>
Date:   Fri Apr 18 20:27:24 2008 +1000

    Revert "SELinux: Made netnode cache adds faster"
    
    This reverts commit 6bf8f41d4efdf9d4eeb4f7df9c591e281f7da93e.
    
    Possible cause of slab corruption in -mm.



-- 
James Morris
<jmorris@namei.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
