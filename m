Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 94D9C6B0336
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 10:14:04 -0400 (EDT)
Date: Fri, 20 Aug 2010 16:14:00 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH] Make is_mem_section_removable more conformable with
 offlining code
Message-ID: <20100820141400.GD4636@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi.kleen@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Haicheng Li <haicheng.li@linux.intel.com>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,
what do you think about the patch below?
