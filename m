Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 74C736B0260
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 17:02:38 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id y16so11115088wmd.6
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 14:02:38 -0800 (PST)
Received: from mail-wj0-f193.google.com (mail-wj0-f193.google.com. [209.85.210.193])
        by mx.google.com with ESMTPS id e138si5382380wmd.25.2016.12.16.14.02.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 14:02:37 -0800 (PST)
Received: by mail-wj0-f193.google.com with SMTP id j10so16061540wjb.3
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 14:02:37 -0800 (PST)
Date: Fri, 16 Dec 2016 23:02:35 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] bpf: do not use KMALLOC_SHIFT_MAX
Message-ID: <20161216220235.GD7645@dhcp22.suse.cz>
References: <20161215164722.21586-1-mhocko@kernel.org>
 <20161215164722.21586-2-mhocko@kernel.org>
 <20161216180209.GA77597@ast-mbp.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161216180209.GA77597@ast-mbp.thefacebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Cc: linux-mm@kvack.org, Cristopher Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Alexei Starovoitov <ast@kernel.org>, netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>

On Fri 16-12-16 10:02:10, Alexei Starovoitov wrote:
> On Thu, Dec 15, 2016 at 05:47:21PM +0100, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > 01b3f52157ff ("bpf: fix allocation warnings in bpf maps and integer
> > overflow") has added checks for the maximum allocateable size. It
> > (ab)used KMALLOC_SHIFT_MAX for that purpose. While this is not incorrect
> > it is not very clean because we already have KMALLOC_MAX_SIZE for this
> > very reason so let's change both checks to use KMALLOC_MAX_SIZE instead.
> > 
> > Cc: Alexei Starovoitov <ast@kernel.org>
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> Nack until the patches 1 and 2 are reversed.

I do not insist on ordering. The thing is that it shouldn't matter all
that much. Or are you worried about bisectability?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
