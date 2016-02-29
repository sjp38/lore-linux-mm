Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 6C295828E4
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 05:09:29 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id l68so29393743wml.0
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 02:09:29 -0800 (PST)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.134])
        by mx.google.com with ESMTPS id k188si19594097wmd.53.2016.02.29.02.09.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Feb 2016 02:09:28 -0800 (PST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] staging/goldfish: use 6-arg get_user_pages()
Date: Mon, 29 Feb 2016 11:09:20 +0100
Message-ID: <4257177.cb22GWAUkR@wuerfel>
In-Reply-To: <20160226132812.a81d46c0151cb47f9433909f@linux-foundation.org>
References: <1456488033-4044939-1-git-send-email-arnd@arndb.de> <20160226132812.a81d46c0151cb47f9433909f@linux-foundation.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Jin Qian <jinqian@android.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>

On Friday 26 February 2016 13:28:12 Andrew Morton wrote:
> On Fri, 26 Feb 2016 12:59:43 +0100 Arnd Bergmann <arnd@arndb.de> wrote:
> > The API change is currently only in the mm/pkeys branch of the
> > tip tree, while the goldfish_pipe driver started using the
> > old API in the staging/next branch.
> >
> > Andrew could pick it up into linux-mm in the meantime, or I can
> > resend it at some later point if nobody else does the change
> > after 4.6-rc1.
> 
> This is one for Ingo.
> 
...
> 
> This removes the first two arguments, which are now the default.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Cc: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: Ingo Molnar <mingo@elte.hu>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

As mentioned in my comment above, the patch can only get added
after the staging/next tree has also been merged, which I think
Ingo doesn't want to add to the tip tree.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
