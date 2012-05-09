Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id C47C06B0083
	for <linux-mm@kvack.org>; Wed,  9 May 2012 13:35:33 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so1052552pbb.14
        for <linux-mm@kvack.org>; Wed, 09 May 2012 10:35:33 -0700 (PDT)
Date: Wed, 9 May 2012 10:35:28 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [patch 00/10] (no)bootmem bits for 3.5
Message-ID: <20120509173528.GD24636@google.com>
References: <1336390672-14421-1-git-send-email-hannes@cmpxchg.org>
 <20120507204113.GD10521@merkur.ravnborg.org>
 <20120507220142.GA1202@cmpxchg.org>
 <20120508175748.GA11906@merkur.ravnborg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120508175748.GA11906@merkur.ravnborg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sam Ravnborg <sam@ravnborg.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Gavin Shan <shangw@linux.vnet.ibm.com>, David Miller <davem@davemloft.net>, Yinghai Lu <yinghai@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>

Hello,

On Tue, May 08, 2012 at 07:57:48PM +0200, Sam Ravnborg wrote:
> > It was used on x86-32 numa to try all bootmem allocations from node 0
> > first (see only remaining definition of bootmem_arch_preferred_node),
> > which AFAICS nobootmem no longer respects.
> > 
> > Shouldn't this be fixed instead?
> I do not know. Tejun / Yinghai?

Indeed, preferring node 0 for bootmem allocation on x86_32 got lost
across the nobootmem changes.  I followed the git history and
preferring NODE_DATA(0) goes back to the initial git branch creation
time (2.6.12) and I couldn't find any explanation, and nobody
complained about the changed behavior.  hpa, do you know why the code
to prefer node 0 for bootmem allocations was added in the first place?
Maybe we can just remove it?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
