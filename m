Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id CD78E6B020B
	for <linux-mm@kvack.org>; Fri, 14 Sep 2012 08:08:51 -0400 (EDT)
Date: Fri, 14 Sep 2012 14:08:49 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH v3] memcg: clean up networking headers file inclusion
Message-ID: <20120914120849.GL28039@dhcp22.suse.cz>
References: <20120914112118.GG28039@dhcp22.suse.cz>
 <50531339.1000805@parallels.com>
 <20120914113400.GI28039@dhcp22.suse.cz>
 <50531696.1080708@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50531696.1080708@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Sachin Kamat <sachin.kamat@linaro.org>

On Fri 14-09-12 15:35:50, Glauber Costa wrote:
[...]
> So, *right now* this code is used only for inet code, so I won't oppose
> your patch on this basis. I'll reuse it for kmem, but I am happy to just
> rebase it.

Hmm, I guess I was too strict after all. memcg_init_kmem doesn't need
CONFIG_INET gueard as both mem_cgroup_sockets_{init,destroy} are defined
empty for !CONFIG_INET. All other functions guarded in INET&&KMEM combo
seem to be networking specific.
Updated patch bellow:
---
