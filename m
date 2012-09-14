Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 260966B01FE
	for <linux-mm@kvack.org>; Fri, 14 Sep 2012 07:21:21 -0400 (EDT)
Date: Fri, 14 Sep 2012 13:21:18 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH v2] memcg: clean up networking headers file inclusion
Message-ID: <20120914112118.GG28039@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, Sachin Kamat <sachin.kamat@linaro.org>

Hi,
so I did some more changes to ifdefery of sock kmem part. The patch is
below. 
Glauber please have a look at it. I do not think any of the
functionality wrapped inside CONFIG_MEMCG_KMEM without CONFIG_INET is
reusable for generic CONFIG_MEMCG_KMEM, right?
---
