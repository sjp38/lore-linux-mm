Message-ID: <470B1C77.1080001@google.com>
Date: Mon, 08 Oct 2007 23:15:19 -0700
From: Ethan Solomita <solo@google.com>
MIME-Version: 1.0
Subject: Re: [PATCH/RFC 4/5] Mem Policy:  cpuset-independent interleave	policy
References: <20070830185053.22619.96398.sendpatchset@localhost>	 <20070830185122.22619.56636.sendpatchset@localhost>	 <46E86148.9060400@google.com> <1189690357.5013.19.camel@localhost>
In-Reply-To: <1189690357.5013.19.camel@localhost>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, ak@suse.de, mtk-manpages@gmx.net, clameter@sgi.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

MPOL_CONTEXT set? That's what's happening with this patch, and I expect 
it'll confuse userland apps, e.g. numactl.
	-- Ethan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
