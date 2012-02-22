Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 2C69B6B004A
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 23:19:13 -0500 (EST)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH v2 00/22] mm: lru_lock splitting
References: <20120220171138.22196.65847.stgit@zurg>
Date: Tue, 21 Feb 2012 20:19:19 -0800
In-Reply-To: <20120220171138.22196.65847.stgit@zurg> (Konstantin Khlebnikov's
	message of "Mon, 20 Feb 2012 21:22:35 +0400")
Message-ID: <m2boor33g8.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Konstantin Khlebnikov <khlebnikov@openvz.org> writes:

Konstantin,

> There complete patch-set with my lru_lock splitting
> plus all related preparations and cleanups rebased to next-20120210

On large systems we're also seeing lock contention on the lru_lock
without using memcgs. Any thoughts how this could be extended for this
situation too?

Thanks,

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
