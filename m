Date: Fri, 04 Jul 2003 12:20:02 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: 2.5.74-mm1 fails to boot due to APIC trouble, 2.5.73mm3 works.
Message-ID: <14820000.1057346400@[10.10.2.4]>
In-Reply-To: <20030704183106.GC955@holomorphy.com>
References: <20030703023714.55d13934.akpm@osdl.org> <Pine.LNX.4.53.0307041139150.24383@montezuma.mastecende.com> <13170000.1057335490@[10.10.2.4]> <20030704183106.GC955@holomorphy.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Zwane Mwaikambo <zwane@arm.linux.org.uk>, Helge Hafting <helgehaf@aitel.hist.no>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> Yeah, things taking logical apicids, and turning them into cpu numbers
>> presumably shouldn't have to touch that.
> 
> The bitmap is wider than the function wants. The change is fine, despite
> your abuse of phys_cpu_present_map.

I'm happy to remove the abuse of phys_cpu_present_map, seeing as we now
have a reason to do so. That would actually seem a much cleaner solution
to these problems than creating a whole new data type, which still doesn't
represent what it claims to


M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
