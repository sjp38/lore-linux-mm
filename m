Date: Sat, 5 Apr 2003 08:31:58 -0500 (EST)
From: Rik van Riel <riel@imladris.surriel.com>
Subject: Re: objrmap and vmtruncate
In-Reply-To: <8950000.1049518163@[10.10.2.4]>
Message-ID: <Pine.LNX.4.50L.0304050831400.2553-100000@imladris.surriel.com>
References: <20030405024414.GP16293@dualathlon.random>
 <Pine.LNX.4.44.0304042255390.32336-100000@chimarrao.boston.redhat.com>
 <20030405041018.GG993@holomorphy.com> <8950000.1049518163@[10.10.2.4]>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, Andrea Arcangeli <andrea@suse.de>, Andrew Morton <akpm@digeo.com>, mingo@elte.hu, hugh@veritas.com, dmccr@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 4 Apr 2003, Martin J. Bligh wrote:

> I don't think we have an app that has 1000 processes mapping the whole
> file 1000 times per process. If we do, shooting the author seems like
> the best course of action to me.

Please, don't shoot akpm ;)

Rik
-- 
Engineers don't grow up, they grow sideways.
http://www.surriel.com/		http://kernelnewbies.org/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
