Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f178.google.com (mail-qk0-f178.google.com [209.85.220.178])
	by kanga.kvack.org (Postfix) with ESMTP id 7E1E36B0005
	for <linux-mm@kvack.org>; Wed, 20 Jan 2016 10:49:54 -0500 (EST)
Received: by mail-qk0-f178.google.com with SMTP id s68so4498087qkh.3
        for <linux-mm@kvack.org>; Wed, 20 Jan 2016 07:49:54 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id s77si31034266qhb.33.2016.01.20.07.49.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jan 2016 07:49:53 -0800 (PST)
Subject: Re: mm, vmstat: kernel BUG at mm/vmstat.c:1408!
References: <5674A5C3.1050504@oracle.com>
 <20160120143719.GF14187@dhcp22.suse.cz> <569FA01A.4070200@oracle.com>
 <20160120151007.GG14187@dhcp22.suse.cz>
 <alpine.DEB.2.20.1601200919520.21490@east.gentwo.org>
From: Sasha Levin <sasha.levin@oracle.com>
Message-ID: <569FAC90.5030407@oracle.com>
Date: Wed, 20 Jan 2016 10:49:36 -0500
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1601200919520.21490@east.gentwo.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On 01/20/2016 10:20 AM, Christoph Lameter wrote:
> On Wed, 20 Jan 2016, Michal Hocko wrote:
> 
>> > On Wed 20-01-16 09:56:26, Sasha Levin wrote:
>>> > > On 01/20/2016 09:37 AM, Michal Hocko wrote:
>>>> > > > I am just reading through this old discussion again because "vmstat:
>>>> > > > make vmstat_updater deferrable again and shut down on idle" which seems
>>>> > > > to be the culprit AFAIU has been merged as 0eb77e988032 and I do not see
>>>> > > > any follow up fix merged to linus tree
>>> > >
>>> > > So this isn't an "old" discussion - the bug is very much there and I can
>>> > > hit it easily. As a workaround I've "disabled" vmstat.
>> >
>> > Well the report is since 18th Dec which is over month old. Should we
>> > revert 0eb77e988032 as a pre caution and make sure this is done properly
>> > in -mm tree. AFAIR none of the proposed fix worked without other
>> > fallouts?
> Seems that we are unable to get enough information to reproduce the issue?

As I've mentioned - this reproduces frequently. I'd be happy to add in debug
information into the kernel that might help you reproduce it, but as it seems
like a timing issue, I can't provide a simple reproducer.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
