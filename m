Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 61E6C6B0093
	for <linux-mm@kvack.org>; Mon,  4 May 2015 04:38:09 -0400 (EDT)
Received: by wicmx19 with SMTP id mx19so72212741wic.1
        for <linux-mm@kvack.org>; Mon, 04 May 2015 01:38:09 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ev18si21638452wjd.73.2015.05.04.01.38.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 04 May 2015 01:38:08 -0700 (PDT)
Date: Mon, 4 May 2015 10:38:06 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 06/13] mm: meminit: Inline some helper functions
Message-ID: <20150504083806.GC24296@dhcp22.suse.cz>
References: <1430231830-7702-1-git-send-email-mgorman@suse.de>
 <1430231830-7702-7-git-send-email-mgorman@suse.de>
 <20150504083356.GA24308@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20150504083356.GA24308@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Waiman Long <waiman.long@hp.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

I have taken this into my mm git tree for now. I guess Andrew will fold
it into the original patch later.

---
