Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id 21B286B0009
	for <linux-mm@kvack.org>; Sat, 13 Feb 2016 00:15:13 -0500 (EST)
Received: by mail-qg0-f46.google.com with SMTP id b67so77791622qgb.1
        for <linux-mm@kvack.org>; Fri, 12 Feb 2016 21:15:13 -0800 (PST)
Received: from e19.ny.us.ibm.com (e19.ny.us.ibm.com. [129.33.205.209])
        by mx.google.com with ESMTPS id p89si19887603qkp.65.2016.02.12.21.15.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 12 Feb 2016 21:15:12 -0800 (PST)
Received: from localhost
	by e19.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sat, 13 Feb 2016 00:15:12 -0500
Received: from b01cxnp23034.gho.pok.ibm.com (b01cxnp23034.gho.pok.ibm.com [9.57.198.29])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id BEC7FC90045
	for <linux-mm@kvack.org>; Sat, 13 Feb 2016 00:15:07 -0500 (EST)
Received: from d01av05.pok.ibm.com (d01av05.pok.ibm.com [9.56.224.195])
	by b01cxnp23034.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u1D5F8qA34144412
	for <linux-mm@kvack.org>; Sat, 13 Feb 2016 05:15:09 GMT
Received: from d01av05.pok.ibm.com (localhost [127.0.0.1])
	by d01av05.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u1D5BkfY013827
	for <linux-mm@kvack.org>; Sat, 13 Feb 2016 00:11:46 -0500
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH V2 00/29] Book3s abstraction in preparation for new MMU model
In-Reply-To: <20160212041457.GE13831@oak.ozlabs.ibm.com>
References: <1454923241-6681-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20160212041457.GE13831@oak.ozlabs.ibm.com>
Date: Sat, 13 Feb 2016 10:45:04 +0530
Message-ID: <87wpq9qjhj.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Mackerras <paulus@ozlabs.org>
Cc: benh@kernel.crashing.org, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

Paul Mackerras <paulus@ozlabs.org> writes:

> On Mon, Feb 08, 2016 at 02:50:12PM +0530, Aneesh Kumar K.V wrote:
>> Hello,
>> 
>> This is a large series, mostly consisting of code movement. No new features
>> are done in this series. The changes are done to accomodate the upcoming new memory
>> model in future powerpc chips. The details of the new MMU model can be found at
>> 
>>  http://ibm.biz/power-isa3 (Needs registration). I am including a summary of the changes below.
>
> This series doesn't seem to apply against either v4.4 or Linus'
> current master.  What is this patch against?
>

The patchset have dependencies against other patcheset posted to the
list. The best option is to pull the branch mentioned instead of trying to
apply them individually.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
