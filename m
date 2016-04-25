Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 31D496B007E
	for <linux-mm@kvack.org>; Mon, 25 Apr 2016 17:04:23 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id b203so108128074pfb.1
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 14:04:23 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id l26si3143pfi.125.2016.04.25.14.04.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Apr 2016 14:04:22 -0700 (PDT)
Date: Mon, 25 Apr 2016 14:04:20 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: SLAB freelist randomization
Message-Id: <20160425140420.cf51815650e7237c7ed9ffbf@linux-foundation.org>
In-Reply-To: <CAJcbSZGSFOQjxbFETA=Zj6g2pRJeyzMBwPGB691AOoCp7VAr3Q@mail.gmail.com>
References: <1460741159-51752-1-git-send-email-thgarnie@google.com>
	<20160415150026.65abbdd5b2ef741cd070c769@linux-foundation.org>
	<1460759160.19090.50.camel@perches.com>
	<CAJcbSZFoVjdcfKjoajL8mmSfz=BPRALx7=0gw3faE2o-hu1RqQ@mail.gmail.com>
	<CAJcbSZGLABr5xEFeopKTj34bL2P-ss=rChs+AYAP_49r1r0NfA@mail.gmail.com>
	<57153751.7080800@redhat.com>
	<CAJcbSZGSFOQjxbFETA=Zj6g2pRJeyzMBwPGB691AOoCp7VAr3Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Garnier <thgarnie@google.com>
Cc: Laura Abbott <labbott@redhat.com>, Joe Perches <joe@perches.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Kees Cook <keescook@chromium.org>, Greg Thelen <gthelen@google.com>, Laura Abbott <labbott@fedoraproject.org>, kernel-hardening@lists.openwall.com, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Mon, 18 Apr 2016 12:52:30 -0700 Thomas Garnier <thgarnie@google.com> wrote:

> I agree, if we had a generic way to pass entropy across boots on all
> architecture that would be amazing. I will let the SLAB maintainers to
> decide on requiring CONFIG_ARCH_RANDOM or documenting it.

In our world, requiring that sort of attention from maintainers
requires a pretty active level of pinging, poking and harrassing ;)

I do think that if you stick with get_random_bytes_arch() then it need
a comment explaining why.

And I (still) don't think that get_random_bytes_arch() actually does
what you want - if CONFIG_ARCH_RANDOM isn't implemented then
get_random_bytes_arch() just fails.  IOW your statement "the arch
version that will fallback on get_random_bytes sub API in the worse
case" is a misconception?  There is no fallback.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
