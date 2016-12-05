Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id A76DE6B0038
	for <linux-mm@kvack.org>; Sun,  4 Dec 2016 22:09:31 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id y71so337321927pgd.0
        for <linux-mm@kvack.org>; Sun, 04 Dec 2016 19:09:31 -0800 (PST)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50060.outbound.protection.outlook.com. [40.107.5.60])
        by mx.google.com with ESMTPS id q63si12963773pfg.266.2016.12.04.19.09.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 04 Dec 2016 19:09:30 -0800 (PST)
Date: Mon, 5 Dec 2016 11:09:20 +0800
From: Huang Shijie <shijie.huang@arm.com>
Subject: Re: [PATCH V2 fix 4/6] mm: mempolicy: intruduce a helper
 huge_nodemask()
Message-ID: <20161205030918.GA13468@sha-win-210.asiapac.arm.com>
References: <1479107259-2011-5-git-send-email-shijie.huang@arm.com>
 <1479279182-31294-1-git-send-email-shijie.huang@arm.com>
 <20161202135845.GL6830@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20161202135845.GL6830@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: akpm@linux-foundation.org, catalin.marinas@arm.com, n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, gerald.schaefer@de.ibm.com, mike.kravetz@oracle.com, linux-mm@kvack.org, will.deacon@arm.com, steve.capper@arm.com, kaly.xin@arm.com, nd@arm.com, linux-arm-kernel@lists.infradead.org

On Fri, Dec 02, 2016 at 02:58:46PM +0100, Michal Hocko wrote:
> On Wed 16-11-16 14:53:02, Huang Shijie wrote:
> > This patch intruduces a new helper huge_nodemask(),
> > we can use it to get the node mask.
> > 
> > This idea of the function is from the init_nodemask_of_mempolicy():
> >    Return true if we can succeed in extracting the node_mask
> > for 'bind' or 'interleave' policy or initializing the node_mask
> > to contain the single node for 'preferred' or 'local' policy.
> 
> It is absolutely unclear how this is going to be used from this patch.
> Please make sure to also use a newly added function in the same patch.
> 
Okay, I will merge this patch into the later patch.

Thanks	
Huang Shijie	

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
