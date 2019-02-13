Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E0D7EC0044B
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 21:12:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8E28E218EA
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 21:12:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="hnZIPCB5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8E28E218EA
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 410438E0003; Wed, 13 Feb 2019 16:12:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3BF318E0001; Wed, 13 Feb 2019 16:12:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2896F8E0003; Wed, 13 Feb 2019 16:12:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id EEA2C8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 16:12:26 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id r24so3340584otk.7
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 13:12:26 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=BVV7ZolsVWZ77ivAzCKG4hVvrPhIZVl55jqYeCDjgHc=;
        b=DyQwu/aDZ7edOLujx456mzsIwxWDsZN3C1yYq11+Ajr+OL+Nsos30TSPgk1tRD6AtY
         l7ySsKFOgCvtR2v4oP+kYiG+/503wDQAe/gpRoOAo/sXrheKk8FwL2C6VFn1AJ0qo0Ki
         CAvW0ZnIelkdbVzw1vr2TrKCyuned12B+56GBVPtRzb64JmrXeBG+Johqy1QCSoacn/Z
         xxSpSd2AwasBQzz8l//Ku/4fJbQDe3g5+cchUOYu40OSxmNDroXCis8KeuxgoSgqfUF+
         x0GGgHFd36UAEErajEBd13DM+6FVOPtwB55TaPsK0dc0siw3U7rwj0ZR3JlEffVliHiZ
         AemQ==
X-Gm-Message-State: AHQUAubtBBUucSRR8jNJQl7dvWDP0FWOS1hGH/3pPmoRd9OI/T2p/MPb
	VncQPJzM/e3cd4HkGOAW3Rn6haycmF5Nl4b9+r0quVyUQ0wUmhrOdR/qKWcyvDVHpzcDeQVY2uQ
	enMPhr8X6ikIds04NloMCH3xfowGvK8I5cEGGAmTD05CkyiUu3n96JhjPhWfy6g2Rc0QrtUcyZY
	GBeaZNsz4lc8pTJLpBx7bQfLs3lMDfrt0jlHkUq2btB3CzkLWTsdHkF45mvOiNGAJbc+V1++uQ/
	3JyGx7o1N4e0JefB3+TWwZ+jQIf65bJgpFZHvhCfl6hAAlnm+G6/fNui4SCc0LDlnbkqk8vHKV6
	TnCIWfBBryExJJxCUZIsyOJmqLASGXBXw/1tMiylMfkaw8sysM5HW/3+K75GREmX+JixG4nhZ8Y
	n
X-Received: by 2002:a54:4613:: with SMTP id p19mr137523oip.88.1550092346526;
        Wed, 13 Feb 2019 13:12:26 -0800 (PST)
X-Received: by 2002:a54:4613:: with SMTP id p19mr137487oip.88.1550092345785;
        Wed, 13 Feb 2019 13:12:25 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550092345; cv=none;
        d=google.com; s=arc-20160816;
        b=pHTopni1tG+Ny0LLGgL5VguV1scJ70RMlA6udROBTQvFQfmK6qhwcYKqn9BD/y1hnf
         EORULi2A5fx6rdpVKuCUjNEbWNKDpxxJ1A54i+K1EpBNImq8WVXdFiWowm0ieuLCttTt
         2+TpmRR/R2Y+/Q4kNh8SY/kcxmeXQNIvy7PLl1dJ3BGrPcaazEGbfscCNfD8L5M6uKY2
         1h6HbBuQt1ITtLu2imxplGxQR/ZIGp41nzjuw9mx+L/GreP5YY65SRa82LXkVM3MF7k1
         C/1qDf6h+JCWY77bXiqrO1sBr5gnaz+cytUp7Xa9us9kaOVnvtSLkB+fYx7m0yltli2b
         OQtg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=BVV7ZolsVWZ77ivAzCKG4hVvrPhIZVl55jqYeCDjgHc=;
        b=UlnIv8qD6YOU0VpFAd3XudrMtxdk2Za0Vj4LgyITpvL4A2B0vptMCNznGBJioUlI4O
         1j62Q08ckwPrWNKbf5f1sq7KYe949f8uiid/x1i/hkCM/heHAO9qlLzFzRSl4ntETDU9
         +Mm9iBrKqQn71dwOYhm7LMMDd8xCdCc2/fsFczldP1DXuYyWeWEazmzgJ4sJD+VXeBs0
         vYq638vtzEd7uZFqXZG44htt0NtkIlh8gO2G+sb1mHar/F2DJzjjLILWcj2bESqdhXnk
         oUV2y195uRj/1iX2No2cANnZXtoBMHEe2UOGR+Ve6EKb9+zhpNgZRkdAuhTwesTXR0gD
         zJJw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=hnZIPCB5;
       spf=pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jannh@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 32sor214369ott.30.2019.02.13.13.12.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 13:12:25 -0800 (PST)
Received-SPF: pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=hnZIPCB5;
       spf=pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jannh@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=BVV7ZolsVWZ77ivAzCKG4hVvrPhIZVl55jqYeCDjgHc=;
        b=hnZIPCB5b4B9VYL4aopvRhUNQQm9ct0xoHEtDhhMxsoLbTI8Lk/nu/a1WYfvyNQclC
         qucJwzlGbm1wabD0r3GAnOBfYQM8T94VodwVZVlsIpehDAgCpJ1GlqdT6z6VOfQWUS6u
         xUW67mAepzazag0HSazVRcfzvvprfBbhumUkazifytWD/EjCxkVWqwdRTDmSXnqFMsMn
         FU+ahg/ywdoGIv3rEPAo1dIehpEwIJk76VTDUGGW0Ubs3ebs4yIskSkL4ZAY4ATnJD7/
         cbHOfw5H8iZJYTjPaz1LPvlAA4faYrmtcdo/kQa0WaRhkyLZAdv60yr7vyeazk/XYnm2
         BldQ==
X-Google-Smtp-Source: AHgI3Ibc01vjE4u34XsCSZEw2Gj9UJofoO4qtYbnjppF4oB2ESnr/mpDGacxGFDhtayggk6aR3C+NLKlTtf4zgvz7jA=
X-Received: by 2002:a9d:5910:: with SMTP id t16mr111037oth.292.1550092345071;
 Wed, 13 Feb 2019 13:12:25 -0800 (PST)
MIME-Version: 1.0
References: <20190213204157.12570-1-jannh@google.com> <20190213125906.eae96c18fe585e060aaf0ef7@linux-foundation.org>
In-Reply-To: <20190213125906.eae96c18fe585e060aaf0ef7@linux-foundation.org>
From: Jann Horn <jannh@google.com>
Date: Wed, 13 Feb 2019 22:11:58 +0100
Message-ID: <CAG48ez2Qo7N-+=y=eFhzw9HfYS3HODAY-zLaubFMGyXEV_nwpg@mail.gmail.com>
Subject: Re: [PATCH] mm: page_alloc: fix ref bias in page_frag_alloc() for
 1-byte allocs
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, 
	Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, 
	Pavel Tatashin <pavel.tatashin@microsoft.com>, Oscar Salvador <osalvador@suse.de>, 
	Mel Gorman <mgorman@techsingularity.net>, Aaron Lu <aaron.lu@intel.com>, 
	Network Development <netdev@vger.kernel.org>, Alexander Duyck <alexander.h.duyck@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 13, 2019 at 9:59 PM Andrew Morton <akpm@linux-foundation.org> wrote:
>
> On Wed, 13 Feb 2019 21:41:57 +0100 Jann Horn <jannh@google.com> wrote:
>
> > The basic idea behind ->pagecnt_bias is: If we pre-allocate the maximum
> > number of references that we might need to create in the fastpath later,
> > the bump-allocation fastpath only has to modify the non-atomic bias value
> > that tracks the number of extra references we hold instead of the atomic
> > refcount. The maximum number of allocations we can serve (under the
> > assumption that no allocation is made with size 0) is nc->size, so that's
> > the bias used.
> >
> > However, even when all memory in the allocation has been given away, a
> > reference to the page is still held; and in the `offset < 0` slowpath, the
> > page may be reused if everyone else has dropped their references.
> > This means that the necessary number of references is actually
> > `nc->size+1`.
> >
> > Luckily, from a quick grep, it looks like the only path that can call
> > page_frag_alloc(fragsz=1) is TAP with the IFF_NAPI_FRAGS flag, which
> > requires CAP_NET_ADMIN in the init namespace and is only intended to be
> > used for kernel testing and fuzzing.
>
> For the net-naive, what is TAP?  It doesn't appear to mean
> drivers/net/tap.c.

It's implemented in drivers/net/tun.c; the combined functionality
implemented in there is called TUN/TAP. TUN refers to providing raw IP
packets to the kernel, TAP refers to providing raw ethernet packets.
It's documented in Documentation/networking/tuntap.txt. The code
that's interesting here is tun_get_user(), which calls into
tun_napi_alloc_frags() if tun_napi_frags_enabled(tfile) is true, which
in turn calls into netdev_alloc_frag(), which ends up in
page_frag_alloc(). This is how you can use it (except that if you were
using it legitimately, you'd be writing an ethernet header, a layer 3
header, and application data instead of writing "aaaaaaaaaaaaaaa" like
me):

================
#define _GNU_SOURCE
#include <stdlib.h>
#include <stdarg.h>
#include <net/if.h>
#include <linux/if.h>
#include <linux/if_tun.h>
#include <err.h>
#include <sys/types.h>
#include <fcntl.h>
#include <string.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/ioctl.h>

void systemf(const char *command, ...) {
  char *full_command;
  va_list ap;
  va_start(ap, command);
  if (vasprintf(&full_command, command, ap) == -1)
    err(1, "vasprintf");
  va_end(ap);
  printf("systemf: <<<%s>>>\n", full_command);
  system(full_command);
}

char *devname;

int tun_alloc(char *name) {
  int fd = open("/dev/net/tun", O_RDWR);
  if (fd == -1)
    err(1, "open tun dev");
  static struct ifreq req = { .ifr_flags =
IFF_TAP|IFF_NO_PI|IFF_NAPI_FRAGS|IFF_NAPI };
  strcpy(req.ifr_name, name);
  if (ioctl(fd, TUNSETIFF, &req))
    err(1, "TUNSETIFF");
  devname = req.ifr_name;
  printf("device name: %s\n", devname);
  return fd;
}

int main(void) {
  int tun_fd = tun_alloc("inject_dev%d");
  systemf("ip link set %s up", devname);

  while (1) {
    struct iovec iov[15];
    for (int i=0; i<sizeof(iov)/sizeof(iov[0]); i++) {
      iov[i].iov_base = "a";
      iov[i].iov_len = 1;
    }
    writev(tun_fd, iov, sizeof(iov)/sizeof(iov[0]));
  }
}
================

> > To test for this issue, put a `WARN_ON(page_ref_count(page) == 0)` in the
> > `offset < 0` path, below the virt_to_page() call, and then repeatedly call
> > writev() on a TAP device with IFF_TAP|IFF_NO_PI|IFF_NAPI_FRAGS|IFF_NAPI,
> > with a vector consisting of 15 elements containing 1 byte each.
> >
> > ...
> >
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -4675,11 +4675,11 @@ void *page_frag_alloc(struct page_frag_cache *nc,
> >               /* Even if we own the page, we do not use atomic_set().
> >                * This would break get_page_unless_zero() users.
> >                */
> > -             page_ref_add(page, size - 1);
> > +             page_ref_add(page, size);
> >
> >               /* reset page count bias and offset to start of new frag */
> >               nc->pfmemalloc = page_is_pfmemalloc(page);
> > -             nc->pagecnt_bias = size;
> > +             nc->pagecnt_bias = size + 1;
> >               nc->offset = size;
> >       }
> >
> > @@ -4695,10 +4695,10 @@ void *page_frag_alloc(struct page_frag_cache *nc,
> >               size = nc->size;
> >  #endif
> >               /* OK, page count is 0, we can safely set it */
> > -             set_page_count(page, size);
> > +             set_page_count(page, size + 1);
> >
> >               /* reset page count bias and offset to start of new frag */
> > -             nc->pagecnt_bias = size;
> > +             nc->pagecnt_bias = size + 1;
> >               offset = size - fragsz;
> >       }
>
> This is probably more a davem patch than a -mm one.

Ah, sorry. I assumed that I just should go by which directory the
patched code is in.

You did just add it to the -mm tree though, right? So I shouldn't
resend it to davem?

