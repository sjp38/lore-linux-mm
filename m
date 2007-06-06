Subject: Re: [PATCH 3/4] mm: move_page_tables{,_up}
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <65dd6fd50706061250l7378ec38gf86c984fe4e00b86@mail.gmail.com>
References: <20070605150523.786600000@chello.nl>
	 <20070605151203.738393000@chello.nl>
	 <65dd6fd50706061206y558e7f90t3740424fae7bdc9c@mail.gmail.com>
	 <1181157134.5676.28.camel@lappy>
	 <65dd6fd50706061250l7378ec38gf86c984fe4e00b86@mail.gmail.com>
Content-Type: text/plain
Date: Wed, 06 Jun 2007 21:53:35 +0200
Message-Id: <1181159615.5676.40.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ollie Wild <aaw@google.com>
Cc: linux-kernel@vger.kernel.org, parisc-linux@lists.parisc-linux.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Andrew Morton <akpm@osdl.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-06-06 at 12:50 -0700, Ollie Wild wrote:
> On 6/6/07, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> > PA-RISC will still need it, right?
> 
> Originally, I thought since the PA-RISC stack grows up, we'd want to
> place the stack at the bottom of memory and have copy_strings() and
> friends work in the opposite direction.  It turns out, though, that
> this ends up being way more headache than it's worth, so I just
> manually grow the stack down with expand_downwards().

Ah, ok. I'll drop this whole patch then.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
