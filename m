Date: Fri, 4 Jul 2003 04:10:22 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.74-mm1 fails to boot due to APIC trouble, 2.5.73mm3 works.
Message-ID: <20030704111022.GE26348@holomorphy.com>
References: <20030703023714.55d13934.akpm@osdl.org> <3F054109.2050100@aitel.hist.no> <20030704093531.GA26348@holomorphy.com> <20030704095004.GB26348@holomorphy.com> <20030704100217.GC26348@holomorphy.com> <20030704100749.GD26348@holomorphy.com> <3F05610C.4050202@aitel.hist.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3F05610C.4050202@aitel.hist.no>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Helge Hafting <helgehaf@aitel.hist.no>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 04, 2003 at 01:12:12PM +0200, Helge Hafting wrote:
> I applied both of your recent patches, and the patched
> 2.5.74-mm1 kernel came up fine. :-)

Terrific!

Sorry about the confusion at first. I apparently made a boo boo when
sizing the physid maps as NR_CPUS bits.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
