Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id A4C5F6B0036
	for <linux-mm@kvack.org>; Wed, 24 Sep 2014 22:40:59 -0400 (EDT)
Received: by mail-wg0-f45.google.com with SMTP id x13so6788010wgg.16
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 19:40:59 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id fw7si1107352wjb.32.2014.09.24.19.40.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Sep 2014 19:40:58 -0700 (PDT)
Date: Wed, 24 Sep 2014 22:40:55 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch v2] mm: memcontrol: do not iterate uninitialized memcgs
Message-ID: <20140925024054.GA4888@cmpxchg.org>
References: <1411612278-4707-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1411612278-4707-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Argh, buggy css_put() against the root.  Hand grenades, everywhere.
Update:

---
