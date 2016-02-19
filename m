Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f178.google.com (mail-qk0-f178.google.com [209.85.220.178])
	by kanga.kvack.org (Postfix) with ESMTP id 3EDAE6B026C
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 21:34:53 -0500 (EST)
Received: by mail-qk0-f178.google.com with SMTP id o6so26270989qkc.2
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 18:34:53 -0800 (PST)
Received: from e36.co.us.ibm.com (e36.co.us.ibm.com. [32.97.110.154])
        by mx.google.com with ESMTPS id 62si705419qgz.42.2016.02.18.18.34.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 18 Feb 2016 18:34:52 -0800 (PST)
Received: from localhost
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 18 Feb 2016 19:34:51 -0700
Received: from b01cxnp22034.gho.pok.ibm.com (b01cxnp22034.gho.pok.ibm.com [9.57.198.24])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id DCAE619D803E
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 19:22:45 -0700 (MST)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by b01cxnp22034.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u1J2YlKg31064182
	for <linux-mm@kvack.org>; Fri, 19 Feb 2016 02:34:47 GMT
Received: from d01av01.pok.ibm.com (localhost [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u1J2Ylgj021408
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 21:34:47 -0500
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH V3 00/30] Book3s abstraction in preparation for new MMU model
In-Reply-To: <20160218231319.GB2765@fergus.ozlabs.ibm.com>
References: <1455814254-10226-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20160218231319.GB2765@fergus.ozlabs.ibm.com>
Date: Fri, 19 Feb 2016 08:04:43 +0530
Message-ID: <87h9h5e8cc.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Mackerras <paulus@ozlabs.org>
Cc: benh@kernel.crashing.org, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

Paul Mackerras <paulus@ozlabs.org> writes:

> On Thu, Feb 18, 2016 at 10:20:24PM +0530, Aneesh Kumar K.V wrote:
>> Hello,
>> 
>> This is a large series, mostly consisting of code movement. No new features
>> are done in this series. The changes are done to accomodate the upcoming new memory
>> model in future powerpc chips. The details of the new MMU model can be found at
>> 
>>  http://ibm.biz/power-isa3 (Needs registration). I am including a summary of the changes below.
>
> This doesn't apply against Linus' current tree - have you already
> posted the prerequisite patches?  If so, what's the subject of the
> 0/N patch of the prerequisite series?


I would suggest to use github to get the tree. Yes I have some dependent
patches and they are not in a single series.

https://github.com/kvaneesh/linux/commits/radix-mmu-v2

Most of the dependent pathces are already in mpe/fixes and the reason to put
them in the branch is to avoid patch apply issues, if we are planning to
take this for next merge window. Since this series involve lots of code
movement, I was worried about errors during cherry-pick/conflict resolution. 


-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
