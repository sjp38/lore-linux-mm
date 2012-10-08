Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 80F6A6B005A
	for <linux-mm@kvack.org>; Mon,  8 Oct 2012 03:03:57 -0400 (EDT)
Message-ID: <1349679825.6982.81.camel@marge.simpson.net>
Subject: Re: [PATCH 18/33] autonuma: teach CFS about autonuma affinity
From: Mike Galbraith <efault@gmx.de>
Date: Mon, 08 Oct 2012 09:03:45 +0200
In-Reply-To: <1349590047.6958.88.camel@marge.simpson.net>
References: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
	 <1349308275-2174-19-git-send-email-aarcange@redhat.com>
	 <1349419285.6984.98.camel@marge.simpson.net>
	 <20121005115455.GH6793@redhat.com>
	 <1349491194.6984.175.camel@marge.simpson.net>
	 <20121006123432.GS6793@redhat.com>
	 <1349590047.6958.88.camel@marge.simpson.net>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <pzijlstr@redhat.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <dhillf@gmail.com>, Andrew Jones <drjones@redhat.com>, Dan Smith <danms@us.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Christoph Lameter <cl@linux.com>, Suresh Siddha <suresh.b.siddha@intel.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On Sun, 2012-10-07 at 08:07 +0200, Mike Galbraith wrote:

> If you have (SMT), MC and NODE domains, waker/wakee are cross
> node, spans don't intersect, affine_sd remains NULL, the whole traverse
> becomes a waste of cycles.

Zzzt, horse-pookey.  NODE spans all.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
