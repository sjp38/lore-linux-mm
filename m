Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 94FB26B0081
	for <linux-mm@kvack.org>; Wed,  9 May 2012 14:08:47 -0400 (EDT)
Received: by dakp5 with SMTP id p5so850754dak.14
        for <linux-mm@kvack.org>; Wed, 09 May 2012 11:08:46 -0700 (PDT)
Date: Wed, 9 May 2012 11:08:42 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [patch 00/10] (no)bootmem bits for 3.5
Message-ID: <20120509180842.GG24636@google.com>
References: <1336390672-14421-1-git-send-email-hannes@cmpxchg.org>
 <20120507204113.GD10521@merkur.ravnborg.org>
 <20120507220142.GA1202@cmpxchg.org>
 <20120508175748.GA11906@merkur.ravnborg.org>
 <20120509173528.GD24636@google.com>
 <alpine.DEB.2.00.1205091252450.11225@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1205091252450.11225@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Sam Ravnborg <sam@ravnborg.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Gavin Shan <shangw@linux.vnet.ibm.com>, David Miller <davem@davemloft.net>, Yinghai Lu <yinghai@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>

Hello, Christoph.

On Wed, May 09, 2012 at 12:54:37PM -0500, Christoph Lameter wrote:
> On some early 32 bit NUMA platforms only node 0 had ZONE_NORMAL memory.
> There is just no other ZONE_NORMAL memory available on other nodes on that
> hardware. But that is ancient history.

I see, but that shouldn't matter (at least anymore), the allocator can
fall back to other nodes just fine and there's no reason to
preemptively prefer node 0.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
