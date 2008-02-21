Message-Id: <20080221203518.544461000@menage.corp.google.com>
Date: Thu, 21 Feb 2008 12:35:18 -0800
From: menage@google.com
Subject: [PATCH 0/2] ResCounter: Add res_counter_read_uint and use it in memory cgroup
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org, xemul@openvz.org, balbir@in.ibm.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

These patches simplify the code required to report values from a
res_counter object in a cgroups control file.

The first patch adds res_counter_read_uint, which simply reports the
current value for a res_counter member.

The second replaces the existing mem_cgroup_read() with a simpler
version that calls res_counter_read_uint().

Signed-off-by: Paul Menage <menage@google.com>

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
