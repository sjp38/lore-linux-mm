Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 650936B009A
	for <linux-mm@kvack.org>; Mon, 18 May 2015 05:12:18 -0400 (EDT)
Received: by wibt6 with SMTP id t6so61714421wib.0
        for <linux-mm@kvack.org>; Mon, 18 May 2015 02:12:18 -0700 (PDT)
Received: from mail-wg0-x232.google.com (mail-wg0-x232.google.com. [2a00:1450:400c:c00::232])
        by mx.google.com with ESMTPS id k8si11682468wia.75.2015.05.18.02.12.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 May 2015 02:12:16 -0700 (PDT)
Received: by wgfl8 with SMTP id l8so28110498wgf.2
        for <linux-mm@kvack.org>; Mon, 18 May 2015 02:12:16 -0700 (PDT)
Date: Mon, 18 May 2015 11:12:15 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 0/2] man-pages: clarify MAP_LOCKED semantic
Message-ID: <20150518091214.GB6393@dhcp22.suse.cz>
References: <1431527892-2996-1-git-send-email-miso@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1431527892-2996-1-git-send-email-miso@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Kerrisk <mtk.manpages@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, linux-mm@kvack.org

On Wed 13-05-15 16:38:10, Michal Hocko wrote:
> Hi,
> during the previous discussion http://marc.info/?l=linux-mm&m=143022313618001&w=2
> it was made clear that making mmap(MAP_LOCKED) semantic really have
> mlock() semantic is too dangerous. Even though we can try to reduce the
> failure space the mmap man page should make it really clear about the
> subtle distinctions between the two. This is what that first patch does.
> The second patch is a small clarification for MAP_POPULATE based on
> David Rientjes feedback.

I have completely forgot about the in kernel doc.
---
