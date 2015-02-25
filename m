Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f179.google.com (mail-we0-f179.google.com [74.125.82.179])
	by kanga.kvack.org (Postfix) with ESMTP id BC45D6B0032
	for <linux-mm@kvack.org>; Wed, 25 Feb 2015 12:58:22 -0500 (EST)
Received: by wesx3 with SMTP id x3so5238732wes.7
        for <linux-mm@kvack.org>; Wed, 25 Feb 2015 09:58:22 -0800 (PST)
Received: from mail-we0-x22d.google.com (mail-we0-x22d.google.com. [2a00:1450:400c:c03::22d])
        by mx.google.com with ESMTPS id f4si74459689wje.8.2015.02.25.09.58.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Feb 2015 09:58:21 -0800 (PST)
Received: by wesq59 with SMTP id q59so5275203wes.1
        for <linux-mm@kvack.org>; Wed, 25 Feb 2015 09:58:20 -0800 (PST)
From: Davidlohr Bueso <dave.bueso@gmail.com>
Message-ID: <1424885948.9419.2.camel@stgolabs.net>
Subject: Re: [PATCH v3 3/3] tomoyo: reduce mmap_sem hold for mm->exe_file
In-Reply-To: <201502252040.IHB78651.OQFSLtFFHOOJMV@I-love.SAKURA.ne.jp>
References: <1424370153.18191.12.camel@stgolabs.net>
	 <201502200711.EIH87066.HSOJLFFOtFVOQM@I-love.SAKURA.ne.jp>
	 <1424449696.2317.0.camel@stgolabs.net>
	 <201502242035.GCI75431.LHQFOOJMFVSFtO@I-love.SAKURA.ne.jp>
	 <1424806966.6539.84.camel@stgolabs.net>
	 <201502252040.IHB78651.OQFSLtFFHOOJMV@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 25 Feb 2015 09:39:08 -0800
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: jmorris@namei.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, takedakn@nttdata.co.jp, linux-security-module@vger.kernel.org, tomoyo-dev-en@lists.sourceforge.jp

On Wed, 2015-02-25 at 20:40 +0900, Tetsuo Handa wrote:
> Davidlohr Bueso wrote:
> > The mm->exe_file is currently serialized with mmap_sem (shared) in order
> > to both safely (1) read the file and (2) compute the realpath by calling
> > tomoyo_realpath_from_path, making it an absolute overkill. Good users will,
> > on the other hand, make use of the more standard get_mm_exe_file(), requiring
> > only holding the mmap_sem to read the value, and relying on reference
> > 
> > Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
> 
> Acked-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> 
> James, will you apply to linux-security.git#next ?
> I'm not using publicly accessible git tree for sending pull requests.

I'm actually trying to route these through Andrew. Because there will be
lock conversions, I'm afraid that if such patches are merged in
different order to Linus' tree, it will break bisectibility as you'd
have races.

Thanks,
Davidlohr



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
