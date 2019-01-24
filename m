Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3629B8E0097
	for <linux-mm@kvack.org>; Thu, 24 Jan 2019 14:25:56 -0500 (EST)
Received: by mail-yw1-f69.google.com with SMTP id x14so3599842ywg.18
        for <linux-mm@kvack.org>; Thu, 24 Jan 2019 11:25:56 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l184sor4042757ywg.146.2019.01.24.11.25.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 24 Jan 2019 11:25:54 -0800 (PST)
Date: Thu, 24 Jan 2019 14:25:52 -0500
From: Chris Down <chris@chrisdown.name>
Subject: Re: [PATCH] mm: Move maxable seq_file logic into a single place
Message-ID: <20190124192552.GA27084@chrisdown.name>
References: <20190124061718.GA15486@chrisdown.name>
 <20190124160935.GB12436@cmpxchg.org>
 <20190124165634.GA13549@chrisdown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20190124165634.GA13549@chrisdown.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Roman Gushchin <guro@fb.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

I'm going to abandon this patch in favour of a patch series which does it 
without macros, but still reduces code duplication fairly significantly. I'll 
send it out shortly.
