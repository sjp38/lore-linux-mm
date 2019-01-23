Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5FF0C8E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 23:42:15 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id v188so867302ita.0
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 20:42:15 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id i135si10029968iti.83.2019.01.22.20.42.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Jan 2019 20:42:14 -0800 (PST)
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH v2 2/2] mm, oom: remove 'prefer children over parent'
 heuristic
Date: Wed, 23 Jan 2019 04:41:42 +0000
Message-ID: <20190123044133.GA17489@castle.DHCP.thefacebook.com>
References: <20190121185033.161015-1-shakeelb@google.com>
 <20190121185033.161015-2-shakeelb@google.com>
In-Reply-To: <20190121185033.161015-2-shakeelb@google.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <CD12C87089972E48B9CA64CA7AEA0D5A@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Linus Torvalds <torvalds@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Mon, Jan 21, 2019 at 10:50:32AM -0800, Shakeel Butt wrote:
> From the start of the git history of Linux, the kernel after selecting
> the worst process to be oom-killed, prefer to kill its child (if the
> child does not share mm with the parent). Later it was changed to prefer
> to kill a child who is worst. If the parent is still the worst then the
> parent will be killed.
>=20
> This heuristic assumes that the children did less work than their parent
> and by killing one of them, the work lost will be less. However this is
> very workload dependent. If there is a workload which can benefit from
> this heuristic, can use oom_score_adj to prefer children to be killed
> before the parent.
>=20
> The select_bad_process() has already selected the worst process in the
> system/memcg. There is no need to recheck the badness of its children
> and hoping to find a worse candidate. That's a lot of unneeded racy
> work. Also the heuristic is dangerous because it make fork bomb like
> workloads to recover much later because we constantly pick and kill
> processes which are not memory hogs. So, let's remove this whole
> heuristic.

This is a great cleanup, thanks!

Acked-by: Roman Gushchin <guro@fb.com>
