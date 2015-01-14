Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 3B9416B0032
	for <linux-mm@kvack.org>; Wed, 14 Jan 2015 03:18:50 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id p10so8426253pdj.13
        for <linux-mm@kvack.org>; Wed, 14 Jan 2015 00:18:50 -0800 (PST)
Received: from mail-pd0-x22e.google.com (mail-pd0-x22e.google.com. [2607:f8b0:400e:c02::22e])
        by mx.google.com with ESMTPS id fz12si29828761pdb.171.2015.01.14.00.18.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 14 Jan 2015 00:18:49 -0800 (PST)
Received: by mail-pd0-f174.google.com with SMTP id fp1so8464382pdb.5
        for <linux-mm@kvack.org>; Wed, 14 Jan 2015 00:18:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <54B5957B.5060900@intel.com>
References: <CAPAsAGwn=KcWOgrTHeWCS18jWq2wK0JGJxYDT1Y4RUpim6=OuQ@mail.gmail.com>
	<54B5957B.5060900@intel.com>
Date: Wed, 14 Jan 2015 12:18:48 +0400
Message-ID: <CAPAsAGw7AaSVMQdxfOyN8dTiPY=oFSeFzE4bRBFa0EVhZCOe+A@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] The kernel address sanitizer
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: lsf-pc@lists.linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Sasha Levin <sasha.levin@oracle.com>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Khlebnikov <koct9i@gmail.com>

2015-01-14 1:00 GMT+03:00 Dave Hansen <dave.hansen@intel.com>:
> On 12/25/2014 04:01 AM, Andrey Ryabinin wrote:
>> Seems we've come to agreement that KASan is useful and deserves to be
>> in mainline, yet the feedback on patches is poor.
>> It seems like they are stalled, so I would like to discuss the future
>> of it. I hope this will help in pushing it forward.
>
> I think this should more broadly be a talk about our memory-related
> debugging options.  This is an especially good audience for seeing what
> gets used and if we need to start culling any of them.
>

No objections, I tend to agree with you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
