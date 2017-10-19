Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id B6CBE6B025F
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 14:53:06 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id n69so2412774lfn.18
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 11:53:06 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m5sor519513ljb.81.2017.10.19.11.53.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 19 Oct 2017 11:53:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171019035641.GB23773@intel.com>
References: <CABXGCsPEkwzKUU9OPRDOMue7TpWa4axTWg0FbXZAq+JZmoubGw@mail.gmail.com>
 <20171019035641.GB23773@intel.com>
From: =?UTF-8?B?0JzQuNGF0LDQuNC7INCT0LDQstGA0LjQu9C+0LI=?= <mikhail.v.gavrilov@gmail.com>
Date: Thu, 19 Oct 2017 23:52:49 +0500
Message-ID: <CABXGCsPL0pUHo_M-KxB3mabfdGMSHPC0uchLBBt0JCzF2BYBww@mail.gmail.com>
Subject: Re: swapper/0: page allocation failure: order:0, mode:0x1204010(GFP_NOWAIT|__GFP_COMP|__GFP_RECLAIMABLE|__GFP_NOTRACK),
 nodemask=(null)
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Du, Changbin" <changbin.du@intel.com>
Cc: linux-mm@kvack.org

On 19 October 2017 at 08:56, Du, Changbin <changbin.du@intel.com> wrote:
> On Thu, Oct 19, 2017 at 01:16:48AM +0500, =D0=9C=D0=B8=D1=85=D0=B0=D0=B8=
=D0=BB =D0=93=D0=B0=D0=B2=D1=80=D0=B8=D0=BB=D0=BE=D0=B2 wrote:
> I am curious about this, how can slub try to alloc compound page but the =
order
> is 0? This is wrong.

Nobody seems to know how this could happen. Can any logs shed light on this=
?

--
Best Regards,
Mike Gavrilov.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
