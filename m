Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 9F8C26B0036
	for <linux-mm@kvack.org>; Mon, 22 Sep 2014 12:47:43 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id v10so3626550pde.20
        for <linux-mm@kvack.org>; Mon, 22 Sep 2014 09:47:43 -0700 (PDT)
Received: from homiemail-a8.g.dreamhost.com (homie.mail.dreamhost.com. [208.97.132.208])
        by mx.google.com with ESMTP id hb5si16405075pbb.186.2014.09.22.09.47.42
        for <linux-mm@kvack.org>;
        Mon, 22 Sep 2014 09:47:42 -0700 (PDT)
Message-ID: <1411404460.28679.12.camel@linux-t7sj.site>
Subject: Re: [PATCH] mm: Support compiling out madvise and fadvise
From: Davidlohr Bueso <dave@stgolabs.net>
Date: Mon, 22 Sep 2014 18:47:40 +0200
In-Reply-To: <20140922161109.GA25027@thin>
References: <20140922161109.GA25027@thin>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josh Triplett <josh@joshtriplett.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org

On Mon, 2014-09-22 at 09:11 -0700, Josh Triplett wrote:
> Many embedded systems will not need these syscalls, and omitting them
> saves space.  Add a new EXPERT config option CONFIG_ADVISE_SYSCALLS
> (default y) to support compiling them out.

general question: if a user chooses CONFIG_ADVISE_SYSCALLS=n (or any
config option related to tinyfication) and breaks the system/workload...
will that be acceptable for a kernel pov? In other words, what's the
degree of responsibility the user will have when choosing such builds?

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
