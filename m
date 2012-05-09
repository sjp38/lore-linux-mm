Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id A3AD06B0083
	for <linux-mm@kvack.org>; Wed,  9 May 2012 13:54:42 -0400 (EDT)
Date: Wed, 9 May 2012 12:54:37 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [patch 00/10] (no)bootmem bits for 3.5
In-Reply-To: <20120509173528.GD24636@google.com>
Message-ID: <alpine.DEB.2.00.1205091252450.11225@router.home>
References: <1336390672-14421-1-git-send-email-hannes@cmpxchg.org> <20120507204113.GD10521@merkur.ravnborg.org> <20120507220142.GA1202@cmpxchg.org> <20120508175748.GA11906@merkur.ravnborg.org> <20120509173528.GD24636@google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Sam Ravnborg <sam@ravnborg.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Gavin Shan <shangw@linux.vnet.ibm.com>, David Miller <davem@davemloft.net>, Yinghai Lu <yinghai@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>

On Wed, 9 May 2012, Tejun Heo wrote:

> Indeed, preferring node 0 for bootmem allocation on x86_32 got lost
> across the nobootmem changes.  I followed the git history and
> preferring NODE_DATA(0) goes back to the initial git branch creation
> time (2.6.12) and I couldn't find any explanation, and nobody
> complained about the changed behavior.  hpa, do you know why the code
> to prefer node 0 for bootmem allocations was added in the first place?
> Maybe we can just remove it?

On some early 32 bit NUMA platforms only node 0 had ZONE_NORMAL memory.
There is just no other ZONE_NORMAL memory available on other nodes on that
hardware. But that is ancient history.

Wondering if 32 bit numa machines still exist. If so how do they partition
memory below 1G?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
