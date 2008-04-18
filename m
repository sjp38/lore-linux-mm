Date: Fri, 18 Apr 2008 14:34:39 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: 2.6.25-mm1: not looking good
Message-ID: <20080418123439.GA17013@elte.hu>
References: <20080417160331.b4729f0c.akpm@linux-foundation.org> <20080417164034.e406ef53.akpm@linux-foundation.org> <20080417171413.6f8458e4.akpm@linux-foundation.org> <48080FE7.1070400@windriver.com> <20080418073732.GA22724@elte.hu> <19f34abd0804180446u2d6f17damf391a8c0584358b8@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <19f34abd0804180446u2d6f17damf391a8c0584358b8@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Vegard Nossum <vegard.nossum@gmail.com>
Cc: Jason Wessel <jason.wessel@windriver.com>, Andrew Morton <akpm@linux-foundation.org>, tglx@linutronix.de, penberg@cs.helsinki.fi, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jmorris@namei.org, sds@tycho.nsa.gov
List-ID: <linux-mm.kvack.org>

* Vegard Nossum <vegard.nossum@gmail.com> wrote:

> With the patch below, it seems 100% reproducible to me (7 out of 7 
> bootups hung).
> 
> The number of loops it could do before hanging were, in order: 697, 
> 898, 237, 55, 45, 92, 59

cool! Jason: i think that particular self-test should be repeated 1000 
times before reporting success ;-)

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
