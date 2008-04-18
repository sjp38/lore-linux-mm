Date: Thu, 17 Apr 2008 22:49:08 -0700
From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: 2.6.25-mm1: not looking good
Message-ID: <20080417224908.67cec814@laptopd505.fenrus.org>
In-Reply-To: <20080417160331.b4729f0c.akpm@linux-foundation.org>
References: <20080417160331.b4729f0c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, James Morris <jmorris@namei.org>, Stephen Smalley <sds@tycho.nsa.gov>
List-ID: <linux-mm.kvack.org>

On Thu, 17 Apr 2008 16:03:31 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> 
> I repulled all the trees an hour or two ago, installed everything on
> an 8-way x86_64 box and:
> 
> 
> stack-protector:
> 
> Testing -fstack-protector-all feature
> No -fstack-protector-stack-frame!
> -fstack-protector-all test failed

do you have a stack-protector capable GCC? I guess not.

This is a catch-22. You do not have stack-protector. Should we make that 
a silent failure? or do you want to know that you don't have a security
feature you thought you had.... complaining seems to be the right thing to do imo.



-- 
If you want to reach me at my work email, use arjan@linux.intel.com
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
