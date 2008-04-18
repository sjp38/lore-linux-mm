Date: Fri, 18 Apr 2008 09:24:57 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: 2.6.25-mm1: not looking good
Message-ID: <20080418072457.GB18044@elte.hu>
References: <20080417160331.b4729f0c.akpm@linux-foundation.org> <84144f020804172340l79f9c815u42e4dad69dada299@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <84144f020804172340l79f9c815u42e4dad69dada299@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, James Morris <jmorris@namei.org>, Stephen Smalley <sds@tycho.nsa.gov>
List-ID: <linux-mm.kvack.org>

* Pekka Enberg <penberg@cs.helsinki.fi> wrote:

> Andrew, you don't seem to have slab debugging enabled:
> 
> # CONFIG_DEBUG_SLAB is not set
> 
> And quite frankly, the oops looks unlikely to be a slab bug but rather 
> a plain old slab corruption cause by the callers...

hm, there's sel_netnode_free() in the stackframe - that's from 
security/selinux/netnode.c. Andrew, any recent changes in that area?

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
