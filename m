Date: Fri, 4 Apr 2003 19:22:01 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: objrmap and vmtruncate
Message-Id: <20030404192201.75794957.akpm@digeo.com>
In-Reply-To: <12880000.1049508832@flay>
References: <Pine.LNX.4.44.0304041453160.1708-100000@localhost.localdomain>
	<20030404105417.3a8c22cc.akpm@digeo.com>
	<20030404214547.GB16293@dualathlon.random>
	<20030404150744.7e213331.akpm@digeo.com>
	<20030405000352.GF16293@dualathlon.random>
	<20030404163154.77f19d9e.akpm@digeo.com>
	<12880000.1049508832@flay>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: andrea@suse.de, mingo@elte.hu, hugh@veritas.com, dmccr@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Martin J. Bligh" <mbligh@aracnet.com> wrote:
>
> >   objrmap does not seem to help.  Page clustering might, but is unlikely to
> >   be enabled on the machines which actually care about the overhead.
> 
> eh? Not sure what you mean by that. It helped massively ...
> diffprofile from kernbench showed:
> 
>      -4666   -74.9% page_add_rmap
>     -10666   -92.0% page_remove_rmap
> 
> I'd say that about an 85% reduction in cost is pretty damned fine ;-)
> And that was about a 20% overall reduction in the system time for the
> test too ... that was all for partial objrmap (file backed, not anon).
> 

In the test I use (my patch management scripts, which is basically bash
forking its brains out) objrmap reclaims only 30-50% of the rmap CPU
overhead.

Maybe you had a very high sharing level.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
