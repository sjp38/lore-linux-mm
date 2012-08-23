Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 0AFE16B0044
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 04:40:15 -0400 (EDT)
Received: by lahd3 with SMTP id d3so336017lah.14
        for <linux-mm@kvack.org>; Thu, 23 Aug 2012 01:40:14 -0700 (PDT)
MIME-Version: 1.0
Date: Thu, 23 Aug 2012 16:40:13 +0800
Message-ID: <CAFNq8R7ibTNeRP_Wftwyr7mK6Du4TVysQysgL_RYj+CGf9N2qg@mail.gmail.com>
Subject: Fixup the page of buddy_higher address's calculation
From: Li Haifeng <omycle@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

