Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 017CF6B0003
	for <linux-mm@kvack.org>; Wed, 25 Apr 2018 08:39:53 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id f21so2156955wmh.5
        for <linux-mm@kvack.org>; Wed, 25 Apr 2018 05:39:52 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id m17si895872edr.66.2018.04.25.05.39.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Apr 2018 05:39:51 -0700 (PDT)
Date: Wed, 25 Apr 2018 13:38:23 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH v2] mm: introduce memory.min
Message-ID: <20180425123816.GA3410@castle>
References: <20180423123610.27988-1-guro@fb.com>
 <20180424123002.utwbm54mu46q6aqs@esperanza>
 <20180424135409.GA28080@castle.DHCP.thefacebook.com>
 <20180425105255.ixfuoanb6t4kr6l5@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20180425105255.ixfuoanb6t4kr6l5@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kernel-team@fb.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Tejun Heo <tj@kernel.org>

On Wed, Apr 25, 2018 at 01:52:55PM +0300, Vladimir Davydov wrote:
> On Tue, Apr 24, 2018 at 02:54:15PM +0100, Roman Gushchin wrote:
> > 
> > But what we can do here, is to ignore memory.min of empty cgroups
> > (patch below), it will resolve some edge cases like this.
> 
> Makes sense to me.

Ok, let's keep it as a fallback mechanism.

Thank you!
