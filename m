Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id DA9EA6B00AA
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 12:35:55 -0500 (EST)
Received: by widex7 with SMTP id ex7so32419280wid.0
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 09:35:55 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dr2si9500142wid.108.2015.03.04.09.35.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 04 Mar 2015 09:35:54 -0800 (PST)
Message-ID: <1425490544.19505.11.camel@stgolabs.net>
Subject: Re: [PATCH v3 3/3] tomoyo: reduce mmap_sem hold for mm->exe_file
From: Davidlohr Bueso <dave@stgolabs.net>
Date: Wed, 04 Mar 2015 09:35:44 -0800
In-Reply-To: <201502252040.IHB78651.OQFSLtFFHOOJMV@I-love.SAKURA.ne.jp>
References: <1424370153.18191.12.camel@stgolabs.net>
	 <201502200711.EIH87066.HSOJLFFOtFVOQM@I-love.SAKURA.ne.jp>
	 <1424449696.2317.0.camel@stgolabs.net>
	 <201502242035.GCI75431.LHQFOOJMFVSFtO@I-love.SAKURA.ne.jp>
	 <1424806966.6539.84.camel@stgolabs.net>
	 <201502252040.IHB78651.OQFSLtFFHOOJMV@I-love.SAKURA.ne.jp>
Content-Type: text/plain
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: jmorris@namei.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, takedakn@nttdata.co.jp, linux-security-module@vger.kernel.org, tomoyo-dev-en@lists.sourceforge.jp

poke... making sure this patch isn't lost. Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
