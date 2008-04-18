Received: by wx-out-0506.google.com with SMTP id h31so482068wxd.11
        for <linux-mm@kvack.org>; Fri, 18 Apr 2008 05:41:46 -0700 (PDT)
Message-ID: <19f34abd0804180541l7b4d14a6tb13bdd51dd533d70@mail.gmail.com>
Date: Fri, 18 Apr 2008 14:41:45 +0200
From: "Vegard Nossum" <vegard.nossum@gmail.com>
Subject: Re: 2.6.25-mm1: not looking good
In-Reply-To: <20080418123439.GA17013@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080417160331.b4729f0c.akpm@linux-foundation.org>
	 <20080417164034.e406ef53.akpm@linux-foundation.org>
	 <20080417171413.6f8458e4.akpm@linux-foundation.org>
	 <48080FE7.1070400@windriver.com> <20080418073732.GA22724@elte.hu>
	 <19f34abd0804180446u2d6f17damf391a8c0584358b8@mail.gmail.com>
	 <20080418123439.GA17013@elte.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Jason Wessel <jason.wessel@windriver.com>, Andrew Morton <akpm@linux-foundation.org>, tglx@linutronix.de, penberg@cs.helsinki.fi, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jmorris@namei.org, sds@tycho.nsa.gov
List-ID: <linux-mm.kvack.org>

On Fri, Apr 18, 2008 at 2:34 PM, Ingo Molnar <mingo@elte.hu> wrote:
>
>  * Vegard Nossum <vegard.nossum@gmail.com> wrote:
>
>  > With the patch below, it seems 100% reproducible to me (7 out of 7
>  > bootups hung).
>  >
>  > The number of loops it could do before hanging were, in order: 697,
>  > 898, 237, 55, 45, 92, 59
>
>  cool! Jason: i think that particular self-test should be repeated 1000
>  times before reporting success ;-)

BTW, I just tested a 32-bit config and it hung after 55 iterations as well.

Vegard


-- 
"The animistic metaphor of the bug that maliciously sneaked in while
the programmer was not looking is intellectually dishonest as it
disguises that the error is the programmer's own creation."
	-- E. W. Dijkstra, EWD1036

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
