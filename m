Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 5EF526B0036
	for <linux-mm@kvack.org>; Tue, 26 Aug 2014 14:38:05 -0400 (EDT)
Received: by mail-wi0-f171.google.com with SMTP id hi2so4677209wib.10
        for <linux-mm@kvack.org>; Tue, 26 Aug 2014 11:38:04 -0700 (PDT)
Received: from mailapp01.imgtec.com (mailapp01.imgtec.com. [195.59.15.196])
        by mx.google.com with ESMTP id ha8si5053188wjc.93.2014.08.26.11.38.03
        for <linux-mm@kvack.org>;
        Tue, 26 Aug 2014 11:38:03 -0700 (PDT)
From: Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>
Subject: Re: [PATCH v4 0/2] mm/highmem: make kmap cache coloring aware
Date: Tue, 26 Aug 2014 18:37:52 +0000
Message-ID: <nlshxsgfkahrb2t7cl2hk6q5.1409078269675@email.android.com>
References: <1406941899-19932-1-git-send-email-jcmvbkbc@gmail.com>,<20140825171600.GH25892@linux-mips.org>
In-Reply-To: <20140825171600.GH25892@linux-mips.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ralf Baechle <ralf@linux-mips.org>
Cc: Max Filippov <jcmvbkbc@gmail.com>, "linux-xtensa@linux-xtensa.org" <linux-xtensa@linux-xtensa.org>, Chris Zankel <chris@zankel.net>, Marc
 Gauthier <marc@cadence.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-mips@linux-mips.org" <linux-mips@linux-mips.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, "Steven J.
 Hill" <Steven.Hill@imgtec.com>

16KB page size solution may sometime be a solution:

1) in microcontroller environment then small pages have advantage
in small applications world.

2) some kernel drivers may not fit well a different page size, especially i=
f HW
has an embedded memory translation: GPU, video/audio decoders,
supplement accelerators.

3) finally, somebody can increase cache size faster than page size,
this race never finishes.



Ralf Baechle <ralf@linux-mips.org> wrote:


On Sat, Aug 02, 2014 at 05:11:37AM +0400, Max Filippov wrote:

> this series adds mapping color control to the generic kmap code, allowing
> architectures with aliasing VIPT cache to use high memory. There's also
> use example of this new interface by xtensa.

I haven't actually ported this to MIPS but it certainly appears to be
the right framework to get highmem aliases handled on MIPS, too.

Though I still consider increasing PAGE_SIZE to 16k the preferable
solution because it will entirly do away with cache aliases.

Thanks,

  Ralf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
