Date: Fri, 4 Jul 2003 12:31:35 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.74-mm1 fails to boot due to APIC trouble, 2.5.73mm3 works.
Message-ID: <20030704193135.GF955@holomorphy.com>
References: <20030703023714.55d13934.akpm@osdl.org> <Pine.LNX.4.53.0307041139150.24383@montezuma.mastecende.com> <13170000.1057335490@[10.10.2.4]> <20030704183106.GC955@holomorphy.com> <14820000.1057346400@[10.10.2.4]>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <14820000.1057346400@[10.10.2.4]>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Zwane Mwaikambo <zwane@arm.linux.org.uk>, Helge Hafting <helgehaf@aitel.hist.no>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

At some point in the past, I wrote:
>> The bitmap is wider than the function wants. The change is fine, despite
>> your abuse of phys_cpu_present_map.

On Fri, Jul 04, 2003 at 12:20:02PM -0700, Martin J. Bligh wrote:
> I'm happy to remove the abuse of phys_cpu_present_map, seeing as we now
> have a reason to do so. That would actually seem a much cleaner solution
> to these problems than creating a whole new data type, which still doesn't
> represent what it claims to

Dirtier, but possibly lower line count.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
