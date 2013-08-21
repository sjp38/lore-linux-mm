Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 7C9A06B0032
	for <linux-mm@kvack.org>; Wed, 21 Aug 2013 16:38:07 -0400 (EDT)
Date: Wed, 21 Aug 2013 13:38:04 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: strictlimit feature -v4
Message-Id: <20130821133804.87ca602dd864df712e67342a@linux-foundation.org>
In-Reply-To: <20130821135427.20334.79477.stgit@maximpc.sw.ru>
References: <20130821135427.20334.79477.stgit@maximpc.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maxim Patlasov <mpatlasov@parallels.com>
Cc: riel@redhat.com, jack@suse.cz, dev@parallels.com, miklos@szeredi.hu, fuse-devel@lists.sourceforge.net, xemul@parallels.com, linux-kernel@vger.kernel.org, jbottomley@parallels.com, linux-mm@kvack.org, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, fengguang.wu@intel.com, devel@openvz.org, mgorman@suse.de

On Wed, 21 Aug 2013 17:56:32 +0400 Maxim Patlasov <mpatlasov@parallels.com> wrote:

> The feature prevents mistrusted filesystems to grow a large number of dirty
> pages before throttling. For such filesystems balance_dirty_pages always
> check bdi counters against bdi limits. I.e. even if global "nr_dirty" is under
> "freerun", it's not allowed to skip bdi checks. The only use case for now is
> fuse: it sets bdi max_ratio to 1% by default and system administrators are
> supposed to expect that this limit won't be exceeded.
> 
> The feature is on if a BDI is marked by BDI_CAP_STRICTLIMIT flag.
> A filesystem may set the flag when it initializes its BDI.

Now I think about it, I don't really understand the need for this
feature.  Can you please go into some detail about the problematic
scenarios and why they need fixing?  Including an expanded descritopn
of the term "mistrusted filesystem"?

Is this some theoretical happens-in-the-lab thing, or are real world
users actually hurting due to the lack of this feature?

I think I'll apply it to -mm for now to get a bit of testing, but would
very much like it if Fengguang could find time to review the
implementation, please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
