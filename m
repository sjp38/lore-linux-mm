Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id B4A8B6B0071
	for <linux-mm@kvack.org>; Tue, 13 Jan 2015 17:00:43 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id ft15so5715445pdb.4
        for <linux-mm@kvack.org>; Tue, 13 Jan 2015 14:00:43 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id oc3si28365632pbb.130.2015.01.13.14.00.41
        for <linux-mm@kvack.org>;
        Tue, 13 Jan 2015 14:00:41 -0800 (PST)
Message-ID: <54B5957B.5060900@intel.com>
Date: Tue, 13 Jan 2015 14:00:27 -0800
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [LSF/MM TOPIC] The kernel address sanitizer
References: <CAPAsAGwn=KcWOgrTHeWCS18jWq2wK0JGJxYDT1Y4RUpim6=OuQ@mail.gmail.com>
In-Reply-To: <CAPAsAGwn=KcWOgrTHeWCS18jWq2wK0JGJxYDT1Y4RUpim6=OuQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>, lsf-pc@lists.linux-foundation.org
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Sasha Levin <sasha.levin@oracle.com>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Khlebnikov <koct9i@gmail.com>

On 12/25/2014 04:01 AM, Andrey Ryabinin wrote:
> Seems we've come to agreement that KASan is useful and deserves to be
> in mainline, yet the feedback on patches is poor.
> It seems like they are stalled, so I would like to discuss the future
> of it. I hope this will help in pushing it forward.

I think this should more broadly be a talk about our memory-related
debugging options.  This is an especially good audience for seeing what
gets used and if we need to start culling any of them.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
