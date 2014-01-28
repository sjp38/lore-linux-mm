Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 84EE06B0036
	for <linux-mm@kvack.org>; Tue, 28 Jan 2014 17:25:15 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id kx10so947549pab.35
        for <linux-mm@kvack.org>; Tue, 28 Jan 2014 14:25:15 -0800 (PST)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id sz7si73251pab.232.2014.01.28.14.25.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Jan 2014 14:25:14 -0800 (PST)
Received: by mail-pa0-f43.google.com with SMTP id rd3so951586pab.2
        for <linux-mm@kvack.org>; Tue, 28 Jan 2014 14:25:13 -0800 (PST)
Date: Tue, 28 Jan 2014 14:24:34 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [Lsf-pc] [LSF/MM ATTEND] persistent transparent large
In-Reply-To: <1390943052.16253.31.camel@dabdike>
Message-ID: <alpine.LSU.2.11.1401281420010.2562@eggly.anvils>
References: <alpine.LSU.2.11.1401230334110.1414@eggly.anvils> <20140128193833.GD20939@parisc-linux.org> <1390943052.16253.31.camel@dabdike>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@hansenpartnership.com>
Cc: Matthew Wilcox <matthew@wil.cx>, Hugh Dickins <hughd@google.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org

On Tue, 28 Jan 2014, James Bottomley wrote:
> 
> Then there's the meta problem of is XIP the right approach.  Using
> persistence within the current memory address space as XIP is a natural
> fit for mixed volatile/NV systems, but what happens when they're all NV
> memory?  Should we be discussing some VM based handling mechanisms for
> persistent memory?

Yes (but at present there's nothing on the table: is the cupboard bare?)

Sorry, answer devoid of content, but since it's my thread...

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
