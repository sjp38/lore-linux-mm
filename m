Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f53.google.com (mail-bk0-f53.google.com [209.85.214.53])
	by kanga.kvack.org (Postfix) with ESMTP id 8BBE16B0092
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 06:45:52 -0400 (EDT)
Received: by mail-bk0-f53.google.com with SMTP id r7so16774bkg.40
        for <linux-mm@kvack.org>; Wed, 02 Apr 2014 03:45:51 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id pv3si754614bkb.149.2014.04.02.03.45.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 02 Apr 2014 03:45:50 -0700 (PDT)
Date: Wed, 2 Apr 2014 12:45:17 +0200
From: chrubis@suse.cz
Subject: Re: [PATCH] mm: msync: require either MS_ASYNC or MS_SYNC
Message-ID: <20140402104517.GA20656@rei>
References: <533B04A9.6090405@bbn.com>
 <533B1439.3010403@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <533B1439.3010403@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: Richard Hansen <rhansen@bbn.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Greg Troxel <gdt@ir.bbn.com>

Hi!
> > and there's no good
> > reason to believe that this behavior would have persisted
> > indefinitely.
> > 
> > The msync(2) man page (as currently written in man-pages.git) is
> > silent on the behavior if both flags are unset, so this change should
> > not break an application written by somone who carefully reads the
> > Linux man pages or the POSIX spec.
> 
> Sadly, people do not always carefully read man pages, so there
> remains the chance that a change like this will break applications.
> Aside from standards conformance, what do you see as the benefit
> of the change?

I've looked around Linux Test Project and this change will break a few
testcases, but nothing that couldn't be easily fixed.

The rest of the world may be more problematic though.

-- 
Cyril Hrubis
chrubis@suse.cz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
