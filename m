Date: Fri, 4 Jul 2003 11:32:43 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.74-mm1 fails to boot due to APIC trouble, 2.5.73mm3 works.
Message-ID: <20030704183243.GD955@holomorphy.com>
References: <20030703023714.55d13934.akpm@osdl.org> <Pine.LNX.4.53.0307041139150.24383@montezuma.mastecende.com> <13170000.1057335490@[10.10.2.4]>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <13170000.1057335490@[10.10.2.4]>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Zwane Mwaikambo <zwane@arm.linux.org.uk>, Helge Hafting <helgehaf@aitel.hist.no>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 04, 2003 at 09:18:12AM -0700, Martin J. Bligh wrote:
> Ugh, are you saying the cpumask stuff shrinks masks to < 32 bits if
> NR_CPUS is low enough? If so, I can see more point to the patch, but
> it still seems like violent overkill. Stopping it doing that would
> probably fix it ... I can't imagine it buys you much.

Step off it. This is not overkill. This is correct.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
