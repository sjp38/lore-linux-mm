Date: Mon, 18 Jun 2007 12:54:52 +0200
From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH] mm: More __meminit annotations.
Message-ID: <20070618105452.GA22386@uranus.ravnborg.org>
References: <20070618045229.GA31635@linux-sh.org> <20070618143943.B108.Y-GOTO@jp.fujitsu.com> <20070618074529.GA21222@uranus.ravnborg.org> <a781481a0706180329i688ece9fm4607c273ed3961bc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a781481a0706180329i688ece9fm4607c273ed3961bc@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Satyam Sharma <satyam.sharma@gmail.com>
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>, Paul Mundt <lethal@linux-sh.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


> But then what
> might happen is that everybody would think his particular use of inline
> is correct and beneficial and all users of inline in kernel would end up
> as __always_inline anyway.

You miss that there is a big difference between "beneficial" and "needs".
The latter is used when some assembly code has a specific knowlegde of
how parameters are passed or that the function signature for other good
reasons must not change.
It has nothing to do with "beneficial".
Any use of __always_inline outside arch/* is highly question able.
And most use of *inline* in drivers/* today is due to bad behaving gcc in the past.

	Sam

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
