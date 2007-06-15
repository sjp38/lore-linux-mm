Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Subject: RE: [patch 0/3] no MAX_ARG_PAGES -v2
Date: Fri, 15 Jun 2007 11:49:04 -0700
Message-ID: <617E1C2C70743745A92448908E030B2A01B3467D@scsmsx411.amr.corp.intel.com>
In-Reply-To: <65dd6fd50706151107v784a252aw89a128f255304ef6@mail.gmail.com>
From: "Luck, Tony" <tony.luck@intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ollie Wild <aaw@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, parisc-linux@lists.parisc-linux.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Andrew Morton <akpm@osdl.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

> > >   A good heuristic, though, might be to limit
> > > argument size to a percentage (say 25%) of maximum stack size and
> > > validate this inside copy_strings().
> >
> > This seems to do:
>
> Looks good.

Me too.  As I increase the number of arguments, I now have
a smooth cutover from "works" to "Arg list too long", without
the in between zone where the process is killed.

The IA-32 compatability exec path is now working too (I didn't
stress it too hard, but I did try argument lists up to a megabyte).

Acked-by: Tony Luck <tony.luck@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
