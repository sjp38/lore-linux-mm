Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 6FDCC6B01F3
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 20:58:08 -0400 (EDT)
Date: Tue, 6 Apr 2010 17:56:01 -0400
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 10/14] Add /sys trigger for per-node memory compaction
Message-Id: <20100406175601.b131e9d2.akpm@linux-foundation.org>
In-Reply-To: <20100407093148.d5d1c42f.kamezawa.hiroyu@jp.fujitsu.com>
References: <1270224168-14775-1-git-send-email-mel@csn.ul.ie>
	<1270224168-14775-11-git-send-email-mel@csn.ul.ie>
	<20100406170559.52093bd5.akpm@linux-foundation.org>
	<20100407093148.d5d1c42f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 7 Apr 2010 09:31:48 +0900 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> A cgroup which controls placement of memory is cpuset.

err, yes, that.

> One idea is per cpuset. But per-node seems ok.

Which is superior?

Which maps best onto the way systems are used (and onto ways in which
we _intend_ that systems be used)?

Is the physical node really the best unit-of-administration?  And is
direct access to physical nodes the best means by which admins will
manage things?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
