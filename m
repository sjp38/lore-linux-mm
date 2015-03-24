Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 240AF6B006C
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 09:21:57 -0400 (EDT)
Received: by wgbcc7 with SMTP id cc7so170932245wgb.0
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 06:21:56 -0700 (PDT)
Received: from radon.swed.at (a.ns.miles-group.at. [95.130.255.143])
        by mx.google.com with ESMTPS id wp10si6372496wjc.164.2015.03.24.06.21.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 24 Mar 2015 06:21:55 -0700 (PDT)
Message-ID: <551164ED.5000907@nod.at>
Date: Tue, 24 Mar 2015 14:21:49 +0100
From: Richard Weinberger <richard@nod.at>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 00/11] an introduction of library operating system
 for Linux (LibOS)
References: <1427202642-1716-1-git-send-email-tazaki@sfc.wide.ad.jp>
In-Reply-To: <1427202642-1716-1-git-send-email-tazaki@sfc.wide.ad.jp>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hajime Tazaki <tazaki@sfc.wide.ad.jp>, linux-arch@vger.kernel.org
Cc: Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Jhristoph Lameter <cl@linux.com>, Jekka Enberg <penberg@kernel.org>, Javid Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jndrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, Jeff Dike <jdike@addtoit.com>, Rusty Russell <rusty@rustcorp.com.au>, Mathieu Lacage <mathieu.lacage@gmail.com>

Am 24.03.2015 um 14:10 schrieb Hajime Tazaki:
 > == More information ==
> 
> The crucial difference between UML (user-mode linux) and this approach
> is that we allow multiple network stack instances to co-exist within a
> single process with dlmopen(3) like linking for easy debugging.

Is this the only difference?
We already have arch/um, why do you need arch/lib/ then?
My point is, can't you merge your arch/lib into the existing arch/um stuff?
>From a very rough look your arch/lib seems like a micro UML.

BTW: There was already an idea for having UML as regular library.
See: http://user-mode-linux.sourceforge.net/old/projects.html
"UML as a normal userspace library"

Thanks,
//richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
