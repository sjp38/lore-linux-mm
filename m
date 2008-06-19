Date: Thu, 19 Jun 2008 13:34:36 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH v2] MM: virtual address debug
Message-ID: <20080619113436.GL15228@elte.hu>
References: <20080618135928.GA12803@elte.hu> <1213814136-10812-1-git-send-email-jirislaby@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1213814136-10812-1-git-send-email-jirislaby@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jiri Slaby <jirislaby@gmail.com>
Cc: Ingo Molnar <mingo@redhat.com>, tglx@linutronix.de, hpa@zytor.com, Mike Travis <travis@sgi.com>, Nick Piggin <nickpiggin@yahoo.com.au>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

* Jiri Slaby <jirislaby@gmail.com> wrote:

> I've removed the test from phys_to_nid and made a function from __phys_addr
> only when the debugging is enabled (on x86_32).

applied to tip/x86/mm-debug for more testing. Please send future updates 
as a delta against that branch, it includes a cleanup patch as well. 
Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
