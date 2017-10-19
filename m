Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id E45FD6B0033
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 00:29:01 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id j3so5737880pga.5
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 21:29:01 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id n72si8463887pfg.420.2017.10.18.21.29.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Oct 2017 21:29:00 -0700 (PDT)
Date: Wed, 18 Oct 2017 21:28:59 -0700
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH v1] mm/mempolicy.c: Fix get_nodes() off-by-one error.
Message-ID: <20171019042859.GX5109@tassilo.jf.intel.com>
References: <1507296994-175620-1-git-send-email-luis.felipe.sandoval.castro@intel.com>
 <1507296994-175620-2-git-send-email-luis.felipe.sandoval.castro@intel.com>
 <20171012084633.ipr5cfxsrs3lyb5n@dhcp22.suse.cz>
 <20171012152825.GJ5109@tassilo.jf.intel.com>
 <20171013080403.izjxlrf7ap5zt2d5@dhcp22.suse.cz>
 <A42BA8431884844BBC20FACB734718294A319F85@FMSMSX106.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <A42BA8431884844BBC20FACB734718294A319F85@FMSMSX106.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Sandoval Castro, Luis Felipe" <luis.felipe.sandoval.castro@intel.com>
Cc: Michal Hocko <mhocko@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "mingo@kernel.org" <mingo@kernel.org>, "rientjes@google.com" <rientjes@google.com>, "n-horiguchi@ah.jp.nec.com" <n-horiguchi@ah.jp.nec.com>, "salls@cs.ucsb.edu" <salls@cs.ucsb.edu>, Cristopher Lameter <cl@linux.com>

On Thu, Oct 19, 2017 at 03:48:09AM +0000, Sandoval Castro, Luis Felipe wrote:
> On Tue 18-10-17 10:42:34, Luis Felipe Sandoval Castro wrote:
> 
> Sorry for the delayed replay, from your feedback I don't think my
> patch has any chances of being merged... I'm wondering though,
> if a note in the man pages "range non inclusive" or something
> like that would help to avoid confusions? Thanks

Yes fixing the man pages is a good idea.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
