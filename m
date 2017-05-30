Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 159CB6B0279
	for <linux-mm@kvack.org>; Tue, 30 May 2017 14:53:10 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e131so107933876pfh.7
        for <linux-mm@kvack.org>; Tue, 30 May 2017 11:53:10 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id a2si14782751pgn.3.2017.05.30.11.53.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 May 2017 11:53:07 -0700 (PDT)
Date: Tue, 30 May 2017 19:52:31 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH v2] mm,oom: add tracepoints for oom reaper-related events
Message-ID: <20170530185231.GA13412@castle>
References: <1496145932-18636-1-git-send-email-guro@fb.com>
 <20170530123415.GF7969@dhcp22.suse.cz>
 <20170530133335.GB28148@castle>
 <20170530134552.GI7969@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170530134552.GI7969@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

