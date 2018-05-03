Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 77A6E6B000A
	for <linux-mm@kvack.org>; Thu,  3 May 2018 07:47:09 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id o68so13067815qke.3
        for <linux-mm@kvack.org>; Thu, 03 May 2018 04:47:09 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id c42-v6si2248200qtc.107.2018.05.03.04.47.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 May 2018 04:47:08 -0700 (PDT)
Date: Thu, 3 May 2018 12:45:59 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH v2 RESEND 2/2] mm: ignore memory.min of abandoned memory
 cgroups
Message-ID: <20180503114553.GA8136@castle.DHCP.thefacebook.com>
References: <20180502154710.18737-1-guro@fb.com>
 <20180502154710.18737-2-guro@fb.com>
 <20180503023142.GA4938@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20180503023142.GA4938@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>

On Wed, May 02, 2018 at 07:31:43PM -0700, Matthew Wilcox wrote:
> On Wed, May 02, 2018 at 04:47:10PM +0100, Roman Gushchin wrote:
> > +				 * Abandoned cgroups are loosing protection,
> 
> "losing".
> 

Fixed in v3.

Thanks!
