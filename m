Message-Id: <20071218233514.501149000@sgi.com>
Date: Tue, 18 Dec 2007 15:35:14 -0800
From: travis@sgi.com
Subject: [PATCH 0/1] x86: fix show cpuinfo cpu number always zero
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, Suresh B Siddha <suresh.b.siddha@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

It appears that this patch is missing from the latest 2.6.24 git
kernel as well as the 2.6.24-rc5-mm1 patch?

> Mike, This issue still seems to be present in linus git tree. Perhaps
> the fix in -mm not pushed to mainline yet.
> 
> Can you please raise the flag with Andrew, so that he can push it before
> 2.6.24 gets out
> 

-- 
