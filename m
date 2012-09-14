Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 5308F6B024A
	for <linux-mm@kvack.org>; Fri, 14 Sep 2012 08:18:15 -0400 (EDT)
Date: Fri, 14 Sep 2012 14:18:13 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH] memcg: clean up networking headers file inclusion
Message-ID: <20120914121813.GN28039@dhcp22.suse.cz>
References: <20120914112118.GG28039@dhcp22.suse.cz>
 <50531339.1000805@parallels.com>
 <20120914113400.GI28039@dhcp22.suse.cz>
 <50531696.1080708@parallels.com>
 <20120914120849.GL28039@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20120914120849.GL28039@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Sachin Kamat <sachin.kamat@linaro.org>

And here is another trivial patch on top of the previous patch.
I am not sure whether we care about such old compilers but the change
itself makes some sense on its own.
---
