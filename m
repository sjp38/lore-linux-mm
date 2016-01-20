Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id CBE1A6B0005
	for <linux-mm@kvack.org>; Wed, 20 Jan 2016 10:10:12 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id uo6so6193900pac.1
        for <linux-mm@kvack.org>; Wed, 20 Jan 2016 07:10:12 -0800 (PST)
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com. [209.85.220.44])
        by mx.google.com with ESMTPS id ly9si15737411pab.115.2016.01.20.07.10.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jan 2016 07:10:12 -0800 (PST)
Received: by mail-pa0-f44.google.com with SMTP id cy9so6074494pac.0
        for <linux-mm@kvack.org>; Wed, 20 Jan 2016 07:10:12 -0800 (PST)
Date: Wed, 20 Jan 2016 16:10:08 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mm, vmstat: kernel BUG at mm/vmstat.c:1408!
Message-ID: <20160120151007.GG14187@dhcp22.suse.cz>
References: <5674A5C3.1050504@oracle.com>
 <20160120143719.GF14187@dhcp22.suse.cz>
 <569FA01A.4070200@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <569FA01A.4070200@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Christoph Lameter <cl@gentwo.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On Wed 20-01-16 09:56:26, Sasha Levin wrote:
> On 01/20/2016 09:37 AM, Michal Hocko wrote:
> > I am just reading through this old discussion again because "vmstat:
> > make vmstat_updater deferrable again and shut down on idle" which seems
> > to be the culprit AFAIU has been merged as 0eb77e988032 and I do not see
> > any follow up fix merged to linus tree
> 
> So this isn't an "old" discussion - the bug is very much there and I can
> hit it easily. As a workaround I've "disabled" vmstat.

Well the report is since 18th Dec which is over month old. Should we
revert 0eb77e988032 as a pre caution and make sure this is done properly
in -mm tree. AFAIR none of the proposed fix worked without other
fallouts?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
