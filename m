Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id DEBCD6B0038
	for <linux-mm@kvack.org>; Mon, 23 Feb 2015 21:45:54 -0500 (EST)
Received: by pdjg10 with SMTP id g10so30044403pdj.1
        for <linux-mm@kvack.org>; Mon, 23 Feb 2015 18:45:54 -0800 (PST)
Received: from smtp2.provo.novell.com (smtp2.provo.novell.com. [137.65.250.81])
        by mx.google.com with ESMTPS id us9si5162778pac.165.2015.02.23.18.45.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 23 Feb 2015 18:45:53 -0800 (PST)
Message-ID: <1424745944.6539.52.camel@stgolabs.net>
Subject: Re: [PATCH 3/3] tomoyo: robustify handling of mm->exe_file
From: Davidlohr Bueso <dave@stgolabs.net>
Date: Mon, 23 Feb 2015 18:45:44 -0800
In-Reply-To: <1424449696.2317.0.camel@stgolabs.net>
References: <1424304641-28965-1-git-send-email-dbueso@suse.de>
	 <1424304641-28965-4-git-send-email-dbueso@suse.de>
	 <1424324307.18191.5.camel@stgolabs.net>
	 <201502192007.AFI30725.tHFFOOMVFOQSLJ@I-love.SAKURA.ne.jp>
	 <1424370153.18191.12.camel@stgolabs.net>
	 <201502200711.EIH87066.HSOJLFFOtFVOQM@I-love.SAKURA.ne.jp>
	 <1424449696.2317.0.camel@stgolabs.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, takedakn@nttdata.co.jp, linux-security-module@vger.kernel.org

On Fri, 2015-02-20 at 08:28 -0800, Davidlohr Bueso wrote:

> 8<--------------------------------------------------------------------
> Subject: [PATCH v2 3/3] tomoyo: reduce mmap_sem hold for mm->exe_file


Tetsuo, could you please ack/nack this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
