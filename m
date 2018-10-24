Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4819A6B0007
	for <linux-mm@kvack.org>; Wed, 24 Oct 2018 02:16:53 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id c26-v6so2250436eda.7
        for <linux-mm@kvack.org>; Tue, 23 Oct 2018 23:16:53 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w9-v6si351054edu.214.2018.10.23.23.16.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Oct 2018 23:16:52 -0700 (PDT)
Date: Wed, 24 Oct 2018 08:16:50 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [kvm PATCH 1/2] mm: export __vmalloc_node_range()
Message-ID: <20181024061650.GZ18839@dhcp22.suse.cz>
References: <20181020211200.255171-1-marcorr@google.com>
 <20181020211200.255171-2-marcorr@google.com>
 <20181022200617.GD14374@char.us.oracle.com>
 <20181023123355.GI32333@dhcp22.suse.cz>
 <CAA03e5ENHGQ_5WhiY=Ya+Kpz+jZsR=in5NAwtrW0p8iGqDg5Vw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA03e5ENHGQ_5WhiY=Ya+Kpz+jZsR=in5NAwtrW0p8iGqDg5Vw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marc Orr <marcorr@google.com>
Cc: konrad.wilk@oracle.com, linux-mm@kvack.org, akpm@linux-foundation.org, kvm@vger.kernel.org, Jim Mattson <jmattson@google.com>, David Rientjes <rientjes@google.com>

On Tue 23-10-18 17:10:55, Marc Orr wrote:
> Ack. The user is the 2nd patch in this series, the kvm_intel module,
> which uses this version of vmalloc() to allocate vcpus across
> non-contiguous memory. I will cc everyone here on that 2nd patch for
> context.

Is there any reason to not fold those two into a single one?
-- 
Michal Hocko
SUSE Labs
