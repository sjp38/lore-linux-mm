Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 913186B0031
	for <linux-mm@kvack.org>; Fri, 14 Feb 2014 00:31:38 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id v10so11440487pde.41
        for <linux-mm@kvack.org>; Thu, 13 Feb 2014 21:31:38 -0800 (PST)
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com. [202.81.31.141])
        by mx.google.com with ESMTPS id ye6si4388432pbc.290.2014.02.13.21.31.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 13 Feb 2014 21:31:37 -0800 (PST)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 14 Feb 2014 15:31:33 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 95C702CE8052
	for <linux-mm@kvack.org>; Fri, 14 Feb 2014 16:31:30 +1100 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s1E5VHPk9961882
	for <linux-mm@kvack.org>; Fri, 14 Feb 2014 16:31:17 +1100
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s1E5VTpc009295
	for <linux-mm@kvack.org>; Fri, 14 Feb 2014 16:31:30 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH V2 0/3]  powerpc: Fix random application crashes with NUMA_BALANCING enabled
In-Reply-To: <20140213150639.2b9124797ac4975b6119f6f0@linux-foundation.org>
References: <1392176618-23667-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20140213150639.2b9124797ac4975b6119f6f0@linux-foundation.org>
Date: Fri, 14 Feb 2014 11:01:25 +0530
Message-ID: <87sirm2rbm.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: benh@kernel.crashing.org, paulus@samba.org, riel@redhat.com, mgorman@suse.de, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

Andrew Morton <akpm@linux-foundation.org> writes:

> On Wed, 12 Feb 2014 09:13:35 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
>
>> Hello,
>> 
>> This patch series fix random application crashes observed on ppc64 with numa
>> balancing enabled. Without the patch we see crashes like
>> 
>> anacron[14551]: unhandled signal 11 at 0000000000000041 nip 000000003cfd54b4 lr 000000003cfd5464 code 30001
>> anacron[14599]: unhandled signal 11 at 0000000000000041 nip 000000003efc54b4 lr 000000003efc5464 code 30001
>> 
>
> Random application crashes are bad.  Which kernel version(s) do you think
> need fixing here?
>
> I grabbed the patches but would like to hear from Ben (or something
> approximating him) before doing anything with them, please.
>

Considering this impact only ppc64 and also only when numa balancing is enabled, we
only need to send this upstream. (no need to backport to any other
kernel versions)

We merged numa balancing support for ppc64
(c34a51ce49b40b9667cd7f5cc2e40475af8b4c3d) only in this merge window.

$git describe --contains c34a51ce49b40b9667cd7f5cc2e40475af8b4c3d
v3.14-rc1~80^2~35


-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
