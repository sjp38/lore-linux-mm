Date: Sun, 11 Dec 2005 20:48:40 +0100
From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC 3/6] Make nr_pagecache a per zone counter
Message-ID: <20051211194840.GU11190@wotan.suse.de>
References: <20051210005440.3887.34478.sendpatchset@schroedinger.engr.sgi.com> <20051210005456.3887.94412.sendpatchset@schroedinger.engr.sgi.com> <20051211183241.GD4267@dmt.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20051211183241.GD4267@dmt.cnet>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

> By the way, why does nr_pagecache needs to be an atomic variable on UP systems?

At least on X86 UP atomic doesn't use the LOCK prefix and is thus quite
cheap. I would expect other architectures who care about UP performance
(= not IA64) to be similar.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
