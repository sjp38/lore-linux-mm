Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Subject: RE: [patch] removes MAX_ARG_PAGES
Date: Fri, 25 May 2007 11:48:09 -0700
Message-ID: <617E1C2C70743745A92448908E030B2A018B17DE@scsmsx411.amr.corp.intel.com>
In-Reply-To: <1180020019.7019.133.camel@twins>
From: "Luck, Tony" <tony.luck@intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Ollie Wild <aaw@google.com>, linux-kernel@vger.kernel.org, parisc-linux@lists.parisc-linux.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Andrew Morton <akpm@osdl.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

> I just tried this on an Altix from the test lab, and ia32 bash just
> started.

I don't have any native x86 binaries on my Madison-based testbox, so my
test case was to compile a simple program that counted total length of
argument strings on an x86 box, and copy it to my ia64 box.  So that I
wouldn't have to copy over a bunch of libraries too, I compiled it
with -static.  This is the test case that "hung" my system (re-running
it today from /dev/tty1 instead of from an xterm, I see that it actually
oopsed in rb_next()).  I wasn't even running with a long arglist.  Just
"*" for my home directory (19 files/directories = ~170 bytes).

-Tony

My test program.  Compile on ia32 box with "cc -static -o args args.c"

---- begin args.c ----
main(int argc, char **argv)
{
	int n;

	printf("argc = %d\n", argc);

	n = 0;
	while (--argc)
		n += strlen(*++argv);

	printf("bytes = %d\n", n);
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
