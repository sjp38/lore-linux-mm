From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 0/2] fix hugepage coredump
Date: Thu, 28 Mar 2013 11:42:36 -0400
Message-ID: <1364485358-8745-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, stable@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-Id: linux-mm.kvack.org

Hi,

This small patch series fixes problems on hugepage coredump,
where we cannot include any data on hugepages into coredump.
See individual patches for more details.

Thanks,
Naoya Horiguchi
