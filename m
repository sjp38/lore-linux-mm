Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 8D19D6B0003
	for <linux-mm@kvack.org>; Mon, 21 Dec 2015 16:07:53 -0500 (EST)
Received: by mail-pf0-f179.google.com with SMTP id 78so21374030pfw.2
        for <linux-mm@kvack.org>; Mon, 21 Dec 2015 13:07:53 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id ch2si6018125pad.150.2015.12.21.13.07.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Dec 2015 13:07:52 -0800 (PST)
Subject: Re: mm, vmstat: kernel BUG at mm/vmstat.c:1408!
References: <5674A5C3.1050504@oracle.com>
 <alpine.DEB.2.20.1512210656120.7119@east.gentwo.org>
 <567860EB.4000103@oracle.com>
From: Sasha Levin <sasha.levin@oracle.com>
Message-ID: <56786A22.9030103@oracle.com>
Date: Mon, 21 Dec 2015 16:07:46 -0500
MIME-Version: 1.0
In-Reply-To: <567860EB.4000103@oracle.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 12/21/2015 03:28 PM, Sasha Levin wrote:
> On 12/21/2015 08:08 AM, Christoph Lameter wrote:
>> > On Fri, 18 Dec 2015, Sasha Levin wrote:
>> > 
>>>> >> > [  531.164630] RIP vmstat_update (mm/vmstat.c:1408)
>> > Hmmm.. Yes we need to fold the diffs first before disabling the timer
>> > otherwise the shepherd task may intervene.
>> > 
>> > Does this patch fix it?
> It didn't. With the patch I'm still seeing:

I've also noticed a new warning from the workqueue code which my scripts
didn't pick up before:

[ 3462.380681] BUG: workqueue lockup - pool cpus=2 node=2 flags=0x4 nice=0 stuck for 54s!
[ 3462.522041] workqueue vmstat: flags=0xc
[ 3462.527795]   pwq 4: cpus=2 node=2 flags=0x0 nice=0 active=1/256
[ 3462.554836]     pending: vmstat_update


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
