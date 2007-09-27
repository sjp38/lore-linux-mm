Date: Thu, 27 Sep 2007 13:25:35 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 00/14] Misc cleanups / fixes
Message-Id: <20070927132535.dde87e7e.akpm@linux-foundation.org>
In-Reply-To: <20070925232543.036615409@sgi.com>
References: <20070925232543.036615409@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 25 Sep 2007 16:25:43 -0700
Christoph Lameter <clameter@sgi.com> wrote:

> This is a collection of fixes and cleanups from the slab defrag,
> virtual compound and the large block patchset that are useful
> independent of these patchsets and that were rediffed against
> 2.6.23-rc8-mm1.

Christoph, I think I'll duck these for now - I'm a bit worried about the
even-worse-than-usual stability levels in the 2.6.24 lineup, so I'd prefer
not to churn things in a way which will distract from fixing all that up.

I'll keep the patches, see if I can get them to apply and work around the
-rc1 timeframe.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
