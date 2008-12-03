Date: Tue, 2 Dec 2008 21:56:50 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH  0/21] memcg updates 2008/12/03
Message-Id: <20081202215650.e7621524.akpm@linux-foundation.org>
In-Reply-To: <20081203134718.6b60986f.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081203134718.6b60986f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 3 Dec 2008 13:47:18 +0900 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> This is memcg update series onto
> "The mm-of-the-moment snapshot 2008-12-02-17-08"

Complaints...

- All these patches had filenames in their Subject: lines.  I turned
  these all back into sensible-sounding English titles.

- I think a lot of authorships got lost.  For example, the way these
  patches were sent, you will be identified as the author of
  inactive_anon_is_low-move-to-vmscan.patch, but I don't think you
  were.  So please work out the correct authorship for

	memcg-revert-gfp-mask-fix.patch
	memcg-check-group-leader-fix.patch
	memcg-memoryswap-controller-fix-limit-check.patch
	memcg-swapout-refcnt-fix.patch
	memcg-hierarchy-avoid-unnecessary-reclaim.patch
	inactive_anon_is_low-move-to-vmscan.patch
	mm-introduce-zone_reclaim-struct.patch
	mm-add-zone-nr_pages-helper-function.patch
	mm-make-get_scan_ratio-safe-for-memcg.patch
	memcg-add-null-check-to-page_cgroup_zoneinfo.patch
	memcg-add-inactive_anon_is_low.patch
	memcg-add-mem_cgroup_zone_nr_pages.patch
	memcg-add-zone_reclaim_stat.patch
	memcg-remove-mem_cgroup_cal_reclaim.patch
	memcg-show-reclaim-stat.patch
	memcg-rename-scan-global-lru.patch
	memcg-protect-prev_priority.patch
	memcg-swappiness.patch
	memcg-explain-details-and-test-document.patch

  and let me know?

- Sentences start with capital letters.

- Your patches are missing the ^--- after the changelog.  This
  creates additional work (and potential for mistakes) at the other
  end.

- I didn't check whether any acked-by's got lost.  They may have been...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
