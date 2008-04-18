Date: Fri, 18 Apr 2008 09:09:13 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: 2.6.25-mm1: not looking good
Message-ID: <20080418070913.GA16599@elte.hu>
References: <20080417160331.b4729f0c.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080417160331.b4729f0c.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, James Morris <jmorris@namei.org>, Stephen Smalley <sds@tycho.nsa.gov>, Arjan van de Ven <arjan@infradead.org>
List-ID: <linux-mm.kvack.org>

* Andrew Morton <akpm@linux-foundation.org> wrote:

> 
> I repulled all the trees an hour or two ago, installed everything on an
> 8-way x86_64 box and:
> 
> 
> stack-protector:
> 
> Testing -fstack-protector-all feature
> No -fstack-protector-stack-frame!
> -fstack-protector-all test failed

that's the stackprotector self-test: you probably have a gcc that cannot 
build a proper stackprotector kernel. No damage other than having no 
stackprotector. Arjan Cc:-ed.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
