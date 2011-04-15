Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8C911900086
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 09:51:48 -0400 (EDT)
Date: Fri, 15 Apr 2011 15:51:44 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH] mm: make expand_downwards symmetrical to expand_upwards
Message-ID: <20110415135144.GE8828@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>

Hi,
the following patch is just a cleanup for better readability without any
functional changes. What do you think about it?
---
