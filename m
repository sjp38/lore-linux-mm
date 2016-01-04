Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id ECF526B0007
	for <linux-mm@kvack.org>; Mon,  4 Jan 2016 13:46:32 -0500 (EST)
Received: by mail-ob0-f173.google.com with SMTP id 18so348648638obc.2
        for <linux-mm@kvack.org>; Mon, 04 Jan 2016 10:46:32 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id v8si18719259obt.9.2016.01.04.10.46.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jan 2016 10:46:32 -0800 (PST)
Subject: Re: mm, vmstat: kernel BUG at mm/vmstat.c:1408!
References: <5674A5C3.1050504@oracle.com>
 <alpine.DEB.2.20.1512210656120.7119@east.gentwo.org>
 <567860EB.4000103@oracle.com> <56786A22.9030103@oracle.com>
 <alpine.DEB.2.20.1512211513360.27237@east.gentwo.org>
 <567C522E.50207@oracle.com>
 <alpine.DEB.2.20.1601041158460.26970@east.gentwo.org>
From: Sasha Levin <sasha.levin@oracle.com>
Message-ID: <568ABE04.9060607@oracle.com>
Date: Mon, 4 Jan 2016 13:46:28 -0500
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1601041158460.26970@east.gentwo.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 01/04/2016 01:05 PM, Christoph Lameter wrote:
> On Thu, 24 Dec 2015, Sasha Levin wrote:
> 
>>> Also what workload triggers the BUG()?
>>
>> Fuzzing with trinity inside a KVM guest. I've attached my config.
> 
> Ok build and bootup works fine after fix from Tetsuo to config. Does not
> like my initrd it seems. Is there a root with the tools available somehow?

Will is hosting a stand-alone version here: git://git.kernel.org/pub/scm/linux/kernel/git/will/kvmtool.git


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
