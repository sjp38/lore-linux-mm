Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 417FF6B007B
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 05:15:08 -0400 (EDT)
Message-ID: <4C91E01E.4070209@inria.fr>
Date: Thu, 16 Sep 2010 11:15:10 +0200
From: Brice Goglin <Brice.Goglin@inria.fr>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] Cross Memory Attach
References: <20100915104855.41de3ebf@lilo> <4C90A6C7.9050607@redhat.com> <20100916001232.0c496b02@lilo> <4C91B9E9.4020701@ens-lyon.org>
In-Reply-To: <4C91B9E9.4020701@ens-lyon.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Christopher Yeoh <cyeoh@au1.ibm.com>
Cc: Avi Kivity <avi@redhat.com>, linux-kernel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Le 16/09/2010 08:32, Brice Goglin a ecrit :
> I am the guy doing KNEM so I can comment on this. The I/OAT part of KNEM
> was mostly a research topic, it's mostly useless on current machines
> since the memcpy performance is much larger than I/OAT DMA Engine. We
> also have an offload model with a kernel thread, but it wasn't used a
> lot so far. These features can be ignored for the current discussion.

I've just created a knem branch where I removed all the above, and some
other stuff that are not necessary for normal users. So it just contains
the region management code and two commands to copy between regions or
between a region and some local iovecs.

Commands are visible at (still uses ioctls since it doesn't matter while
discussing the features):
https://gforge.inria.fr/scm/viewvc.php/*checkout*/branches/kernel/driver/linux/knem_main.c?root=knem&content-type=text%2Fplain

And the actual driver is at:
https://gforge.inria.fr/scm/viewvc.php/*checkout*/branches/kernel/common/knem_io.h?root=knem&content-type=text%2Fplain

Brice


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
