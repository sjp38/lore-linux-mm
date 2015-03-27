Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 29CD26B0032
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 23:39:18 -0400 (EDT)
Received: by pacwe9 with SMTP id we9so82757540pac.1
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 20:39:17 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id x4si1016825pdr.44.2015.03.26.20.39.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Mar 2015 20:39:17 -0700 (PDT)
From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [RFC PATCH 00/11] an introduction of library operating system for Linux (LibOS)
In-Reply-To: <5514560A.7040707@nod.at>
References: <1427202642-1716-1-git-send-email-tazaki@sfc.wide.ad.jp> <551164ED.5000907@nod.at> <m2twxacw13.wl@sfc.wide.ad.jp> <55117565.6080002@nod.at> <m2sicuctb2.wl@sfc.wide.ad.jp> <55118277.5070909@nod.at> <m2bnjhcevt.wl@sfc.wide.ad.jp> <55133BAF.30301@nod.at> <m2h9t7bubh.wl@wide.ad.jp> <5514560A.7040707@nod.at>
Date: Fri, 27 Mar 2015 14:01:22 +1030
Message-ID: <87iodnqfp1.fsf@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Weinberger <richard@nod.at>, Hajime Tazaki <tazaki@wide.ad.jp>
Cc: linux-arch@vger.kernel.org, arnd@arndb.de, corbet@lwn.net, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, jdike@addtoit.com, mathieu.lacage@gmail.com

Richard Weinberger <richard@nod.at> writes:
> This also infers that arch/lib will be broken most of the time as
> every time the networking stack references a new symbol it
> has to be duplicated into arch/lib.
>
> But this does not mean that your idea is bad, all I want to say that
> I'm not sure whether arch/lib is the right approach.
> Maybe Arnd has a better idea.

Exactly why I look forward to getting this in-tree.  Jeremy Kerr and I
wrote nfsim back in 2005(!) which stubbed around the netfilter
infrastructure; with failtest and valgrind it found some nasty bugs.  It
was too much hassle to maintain out-of-tree though :(

I look forward to a flood of great bugfixes from this work :)

Cheers,
Rusty.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
