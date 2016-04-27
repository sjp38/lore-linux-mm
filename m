Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id F0E8A6B025F
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 11:40:38 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id y69so94809285oif.0
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 08:40:38 -0700 (PDT)
Received: from resqmta-po-12v.sys.comcast.net (resqmta-po-12v.sys.comcast.net. [2001:558:fe16:19:96:114:154:171])
        by mx.google.com with ESMTPS id m6si10448494ioa.20.2016.04.27.08.40.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Apr 2016 08:40:38 -0700 (PDT)
Date: Wed, 27 Apr 2016 10:40:36 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v4] mm: SLAB freelist randomization
In-Reply-To: <CAJcbSZED2hmEb9KvFcas6S05rN7vDYy+2tUhKRA6Z36Rj-GBfw@mail.gmail.com>
Message-ID: <alpine.DEB.2.20.1604271039520.20042@east.gentwo.org>
References: <1461687670-47585-1-git-send-email-thgarnie@google.com> <20160426161743.f831225a4efb3eb04debe402@linux-foundation.org> <CAJcbSZED2hmEb9KvFcas6S05rN7vDYy+2tUhKRA6Z36Rj-GBfw@mail.gmail.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Garnier <thgarnie@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Kees Cook <keescook@chromium.org>, Greg Thelen <gthelen@google.com>, Laura Abbott <labbott@fedoraproject.org>, kernel-hardening@lists.openwall.com, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Tue, 26 Apr 2016, Thomas Garnier wrote:

> It was discussed a bit before. The intent is to have a similar feature
> for other kernel heap (I know it is possible for SLUB). That's why I
> think it make sense to have a similar config name used for all
> allocators.

Please use CONFIG_SLAB_FREELIST_RANDOM to signify that it is for all slab
allocators. Not SLAB specific.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
