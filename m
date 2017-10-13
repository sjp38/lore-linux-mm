Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id F2A216B0033
	for <linux-mm@kvack.org>; Fri, 13 Oct 2017 04:04:07 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id u27so7329667pfg.12
        for <linux-mm@kvack.org>; Fri, 13 Oct 2017 01:04:07 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n123si277450pgn.35.2017.10.13.01.04.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 13 Oct 2017 01:04:06 -0700 (PDT)
Date: Fri, 13 Oct 2017 10:04:03 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v1] mm/mempolicy.c: Fix get_nodes() off-by-one error.
Message-ID: <20171013080403.izjxlrf7ap5zt2d5@dhcp22.suse.cz>
References: <1507296994-175620-1-git-send-email-luis.felipe.sandoval.castro@intel.com>
 <1507296994-175620-2-git-send-email-luis.felipe.sandoval.castro@intel.com>
 <20171012084633.ipr5cfxsrs3lyb5n@dhcp22.suse.cz>
 <20171012152825.GJ5109@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171012152825.GJ5109@tassilo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: Luis Felipe Sandoval Castro <luis.felipe.sandoval.castro@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, vbabka@suse.cz, mingo@kernel.org, rientjes@google.com, n-horiguchi@ah.jp.nec.com, salls@cs.ucsb.edu, Cristopher Lameter <cl@linux.com>

On Thu 12-10-17 08:28:25, Andi Kleen wrote:
> On Thu, Oct 12, 2017 at 10:46:33AM +0200, Michal Hocko wrote:
> > [CC Christoph who seems to be the author of the code]
> 
> Actually you can blame me. I did the mistake originally.
> It was found many years ago, but then it was already too late
> to change.
> 
> > Andi has voiced a concern about backward compatibility but I am not sure
> > the risk is very high. The current behavior is simply broken unless you
> > use a large maxnode anyway. What kind of breakage would you envision
> > Andi?
> 
> libnuma uses the available number of nodes as max. 
> 
> So it would always lose the last one with your chance.

I must be missing something because libnuma does
if (set_mempolicy(policy, bmp->maskp, bmp->size + 1) < 0)

so it sets max as size + 1 which is exactly what the man page describes.

> Your change would be catastrophic.

I am not sure which change do you mean here. I wasn't proposing any
patch (yet). All I was saying is that the docuementation diagrees with
the in kernel implementation. The only applications that would break
would be those which do not comply to the documentation AFAICS, no?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
