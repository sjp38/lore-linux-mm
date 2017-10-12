Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id B76896B0038
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 11:28:50 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id p87so3588857pfj.21
        for <linux-mm@kvack.org>; Thu, 12 Oct 2017 08:28:50 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id w16si7805534pge.598.2017.10.12.08.28.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Oct 2017 08:28:48 -0700 (PDT)
Date: Thu, 12 Oct 2017 08:28:25 -0700
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH v1] mm/mempolicy.c: Fix get_nodes() off-by-one error.
Message-ID: <20171012152825.GJ5109@tassilo.jf.intel.com>
References: <1507296994-175620-1-git-send-email-luis.felipe.sandoval.castro@intel.com>
 <1507296994-175620-2-git-send-email-luis.felipe.sandoval.castro@intel.com>
 <20171012084633.ipr5cfxsrs3lyb5n@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171012084633.ipr5cfxsrs3lyb5n@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Luis Felipe Sandoval Castro <luis.felipe.sandoval.castro@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, vbabka@suse.cz, mingo@kernel.org, rientjes@google.com, n-horiguchi@ah.jp.nec.com, salls@cs.ucsb.edu, Cristopher Lameter <cl@linux.com>

On Thu, Oct 12, 2017 at 10:46:33AM +0200, Michal Hocko wrote:
> [CC Christoph who seems to be the author of the code]

Actually you can blame me. I did the mistake originally.
It was found many years ago, but then it was already too late
to change.

> Andi has voiced a concern about backward compatibility but I am not sure
> the risk is very high. The current behavior is simply broken unless you
> use a large maxnode anyway. What kind of breakage would you envision
> Andi?

libnuma uses the available number of nodes as max. 

So it would always lose the last one with your chance.

Your change would be catastrophic.

The only way to fix it really would be to define
a new syscall. But I don't think it is needed, 
the existing maxnode+1 interface works
(just should be properly documented)

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
