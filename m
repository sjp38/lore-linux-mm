Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9595E6B0582
	for <linux-mm@kvack.org>; Sun, 16 Jul 2017 09:29:36 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id p5so36593126ioo.13
        for <linux-mm@kvack.org>; Sun, 16 Jul 2017 06:29:36 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id 73si5370000itb.133.2017.07.16.06.29.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Jul 2017 06:29:35 -0700 (PDT)
Date: Sun, 16 Jul 2017 14:29:09 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH] mm: make allocation counters per-order
Message-ID: <20170716132909.GB757@castle>
References: <1499346271-15653-1-git-send-email-guro@fb.com>
 <20170706131941.omod4zl4cyuscmjo@techsingularity.net>
 <20170706144634.GB14840@castle>
 <20170706154704.owxsnyizel6bcgku@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170706154704.owxsnyizel6bcgku@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Rik van Riel <riel@redhat.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org

