Date: Thu, 16 Feb 2006 17:40:50 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [PATCH for 2.6.16] Handle holes in node mask in node fallback
 list initialization
In-Reply-To: <200602170223.34031.ak@suse.de>
Message-ID: <Pine.LNX.4.64.0602161739560.27091@schroedinger.engr.sgi.com>
References: <200602170223.34031.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: torvalds@osdl.org, akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

What happens if another node beyond higest_node comes online later?
Or one node in between comes online?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
