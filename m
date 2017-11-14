Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id A21A66B0253
	for <linux-mm@kvack.org>; Tue, 14 Nov 2017 12:05:34 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id p96so11162403wrb.12
        for <linux-mm@kvack.org>; Tue, 14 Nov 2017 09:05:34 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n41si983691edd.38.2017.11.14.09.05.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 14 Nov 2017 09:05:33 -0800 (PST)
Date: Tue, 14 Nov 2017 17:05:31 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Allocation failure of ring buffer for trace
Message-ID: <20171114170531.clhc43q4wm4pfpfq@suse.de>
References: <9631b871-99cc-82bb-363f-9d429b56f5b9@gmail.com>
 <20171114114633.6ltw7f4y7qwipcqp@suse.de>
 <48b66fc4-ef82-983c-1b3d-b9c0a482bc51@gmail.com>
 <20171114155327.5ugozxxsofqoohv2@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20171114155327.5ugozxxsofqoohv2@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>
Cc: rostedt@goodmis.org, mingo@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, koki.sanagi@us.fujitsu.com

On Tue, Nov 14, 2017 at 03:53:27PM +0000, Mel Gorman wrote:
> > The issue also occurred on distribution kernels. So we have to fix the issue.
> > 
> 
> I'm aware of now bugs against a distribution kernel.

I don't know what happened there. I'm *not* aware of any bugs against a
distribution kernel.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
