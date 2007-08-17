Date: Fri, 17 Aug 2007 14:03:45 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 4/6] Record how many zones can be safely skipped in the
 zonelist
In-Reply-To: <20070817201808.14792.13501.sendpatchset@skynet.skynet.ie>
Message-ID: <Pine.LNX.4.64.0708171402540.9635@schroedinger.engr.sgi.com>
References: <20070817201647.14792.2690.sendpatchset@skynet.skynet.ie>
 <20070817201808.14792.13501.sendpatchset@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Lee.Schermerhorn@hp.com, ak@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Is there any performance improvement because of this patch? It looks 
like processing got more expensive since an additional cacheline needs to 
be fetches to get the skip factor.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
