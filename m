Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id B1E1B8D0040
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 05:28:03 -0400 (EDT)
Received: by wyf19 with SMTP id 19so10980881wyf.14
        for <linux-mm@kvack.org>; Thu, 24 Mar 2011 02:28:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <9bde694e1003020554p7c8ff3c2o4ae7cb5d501d1ab9@mail.gmail.com>
References: <9bde694e1003020554p7c8ff3c2o4ae7cb5d501d1ab9@mail.gmail.com>
Date: Thu, 24 Mar 2011 11:27:59 +0200
Message-ID: <AANLkTinnqtXf5DE+qxkTyZ9p9Mb8dXai6UxWP2HaHY3D@mail.gmail.com>
Subject: Re: kmemleak for MIPS
From: Daniel Baluta <dbaluta@ixiacom.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: naveen yadav <yad.naveen@gmail.com>, Catalin Marinas <catalin.marinas@arm.com>
Cc: linux-mips@linux-mips.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

> I want to check kmemleak for both ARM/MIPS. i am able to find kernel
> patch for ARM at
> http://linux.derkeiler.com/Mailing-Lists/Kernel/2009-04/msg11830.html.
> But I could not able to trace patch for MIPS.

It seems that kmemleak is not supported on MIPS.

According to 'depends on' config entry it is supported on:
x86, arm, ppc, s390, sparc64, superh, microblaze and tile.

C=C4=83t=C4=83lin, can you confirm this? I will send a patch to update
Documentation/kmemleak.txt.

Also, looking forward to work on making kmemleak available on MIPS.

thanks,
Daniel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
