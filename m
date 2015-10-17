Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 8068F82F64
	for <linux-mm@kvack.org>; Sat, 17 Oct 2015 08:08:49 -0400 (EDT)
Received: by padfb7 with SMTP id fb7so2276473pad.2
        for <linux-mm@kvack.org>; Sat, 17 Oct 2015 05:08:49 -0700 (PDT)
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com. [202.81.31.148])
        by mx.google.com with ESMTPS id yx1si36536490pbc.175.2015.10.17.05.08.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Sat, 17 Oct 2015 05:08:48 -0700 (PDT)
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sat, 17 Oct 2015 22:08:44 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 060752CE8052
	for <linux-mm@kvack.org>; Sat, 17 Oct 2015 23:08:41 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t9HC8SUn65339436
	for <linux-mm@kvack.org>; Sat, 17 Oct 2015 23:08:40 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t9HC84xe031774
	for <linux-mm@kvack.org>; Sat, 17 Oct 2015 23:08:04 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/3] mm/powerpc: enabling memory soft dirty tracking
In-Reply-To: <20151016141129.8b014c6d882c475fafe577a9@linux-foundation.org>
References: <cover.1444995096.git.ldufour@linux.vnet.ibm.com> <20151016141129.8b014c6d882c475fafe577a9@linux-foundation.org>
Date: Sat, 17 Oct 2015 17:37:44 +0530
Message-ID: <87io65itpr.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, xemul@parallels.com, linuxppc-dev@lists.ozlabs.org, mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org, criu@openvz.org

Andrew Morton <akpm@linux-foundation.org> writes:

> On Fri, 16 Oct 2015 14:07:05 +0200 Laurent Dufour <ldufour@linux.vnet.ibm.com> wrote:
>
>> This series is enabling the software memory dirty tracking in the
>> kernel for powerpc.  This is the follow up of the commit 0f8975ec4db2
>> ("mm: soft-dirty bits for user memory changes tracking") which
>> introduced this feature in the mm code.
>> 
>> The first patch is fixing an issue in the code clearing the soft dirty
>> bit.  The PTE were not cleared before being modified, leading to hang
>> on ppc64.
>> 
>> The second patch is fixing a build issue when the transparent huge
>> page is not enabled.
>> 
>> The third patch is introducing the soft dirty tracking in the powerpc
>> architecture code. 
>
> I grabbed these patches, but they're more a ppc thing than a core
> kernel thing.  I can merge them into 4.3 with suitable acks or drop
> them if they turn up in the powerpc tree.  Or something else?

patch 1 and patch 2 are fixes for generic code. That can go via -mm
tree. The ppc64 bits should go via linux-powerpc tree. We have changes
in this area pending to be merged upstream and patch 3 will result
in conflicts.


-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
