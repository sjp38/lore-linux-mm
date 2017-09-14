From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 1/3] mm: slab: output reclaimable flag in
 /proc/slabinfo
Date: Thu, 14 Sep 2017 12:27:53 -0500 (CDT)
Message-ID: <alpine.DEB.2.20.1709141227010.529@nuc-kabylake>
References: <1505409289-57031-1-git-send-email-yang.s@alibaba-inc.com> <1505409289-57031-2-git-send-email-yang.s@alibaba-inc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1505409289-57031-2-git-send-email-yang.s@alibaba-inc.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Yang Shi <yang.s@alibaba-inc.com>
Cc: penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-Id: linux-mm.kvack.org

Well /proc/slabinfo is a legacy interface. The infomation if a slab is
reclaimable is available via the slabinfo tool. We would break a format
that is relied upon by numerous tools.
