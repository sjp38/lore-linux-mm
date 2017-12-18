Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3860F6B0033
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 06:00:35 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id x187so6919738oix.3
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 03:00:35 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k41si2170693otb.73.2017.12.18.03.00.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 03:00:33 -0800 (PST)
Subject: Re: pkeys: Support setting access rights for signal handlers
References: <20171212231324.GE5460@ram.oc3035372033.ibm.com>
 <9dc13a32-b1a6-8462-7e19-cfcf9e2c151e@redhat.com>
 <20171213113544.GG5460@ram.oc3035372033.ibm.com>
 <9f86d79e-165a-1b8e-32dd-7e4e8579da59@redhat.com>
 <c220f36f-c04a-50ae-3fd7-2c6245e27057@intel.com>
 <93153ac4-70f0-9d17-37f1-97b80e468922@redhat.com>
 <20171214001756.GA5471@ram.oc3035372033.ibm.com>
 <cf13f6e0-2405-4c58-4cf1-266e8baae825@redhat.com>
 <20171216150910.GA5461@ram.oc3035372033.ibm.com>
 <2eba29f4-804d-b211-1293-52a567739cad@redhat.com>
 <20171216172026.GC5461@ram.oc3035372033.ibm.com>
From: Florian Weimer <fweimer@redhat.com>
Message-ID: <7ab875c5-dc7c-b36e-8612-3d4aaf86a15c@redhat.com>
Date: Mon, 18 Dec 2017 12:00:30 +0100
MIME-Version: 1.0
In-Reply-To: <20171216172026.GC5461@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-mm <linux-mm@kvack.org>, x86@kernel.org, linux-arch <linux-arch@vger.kernel.org>, linux-x86_64@vger.kernel.org, Linux API <linux-api@vger.kernel.org>

On 12/16/2017 06:20 PM, Ram Pai wrote:
> Ok. Sounds like I do not have much to do. My patches in its current form
> will continue to work and provide the semantics you envision.

Thanks for confirming.

>> I'm open to a different way towards conveying this information to
>> userspace.  I don't want to probe for the behavior by sending a
>> signal because that is quite involved and would also be visible in
>> debuggers, confusing programmers.

> I am fine with your proposal.

So how can we move this forward?  Should I submit a single new patch 
with the new flag with a more appropriate name (PKEY_ALLOC_SIGNALINHERIT 
comes to my mind) and the signal inheritance change?

Dave, do you still want to wait for feedback from the x86 maintainer 
regarding a general interface?  Is this really feasible without detailed 
knowledge of the XSAVE output structure?  Otherwise, there probably 
isn't a way around code which explicitly copies the bits we want to 
preserve from the interrupted CPU context to the signal handler context.

Thanks,
Florian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
