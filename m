Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 17DC283096
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 07:16:35 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id p85so11394589lfg.3
        for <linux-mm@kvack.org>; Tue, 30 Aug 2016 04:16:35 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id 198si4022720wmi.81.2016.08.30.04.16.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Aug 2016 04:16:33 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id o80so2675054wme.0
        for <linux-mm@kvack.org>; Tue, 30 Aug 2016 04:16:33 -0700 (PDT)
Date: Tue, 30 Aug 2016 13:16:32 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] oom: warn if we go OOM for higher order and compaction
 is disabled
Message-ID: <20160830111632.GD23963@dhcp22.suse.cz>
References: <1472555667-30348-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1472555667-30348-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Ups, forgot to fold the fix up into the commit.
---
