Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id ABB2C6B0035
	for <linux-mm@kvack.org>; Mon, 25 Aug 2014 19:55:57 -0400 (EDT)
Received: by mail-ig0-f170.google.com with SMTP id h3so4936417igd.1
        for <linux-mm@kvack.org>; Mon, 25 Aug 2014 16:55:57 -0700 (PDT)
Received: from qmta09.westchester.pa.mail.comcast.net (qmta09.westchester.pa.mail.comcast.net. [2001:558:fe14:43:76:96:62:96])
        by mx.google.com with ESMTP id fm20si1233656icb.63.2014.08.25.16.55.56
        for <linux-mm@kvack.org>;
        Mon, 25 Aug 2014 16:55:56 -0700 (PDT)
Message-ID: <53FBCD09.1050003@gentoo.org>
Date: Mon, 25 Aug 2014 19:55:53 -0400
From: Joshua Kinard <kumba@gentoo.org>
MIME-Version: 1.0
Subject: Re: [PATCH v4 0/2] mm/highmem: make kmap cache coloring aware
References: <1406941899-19932-1-git-send-email-jcmvbkbc@gmail.com> <20140825171600.GH25892@linux-mips.org>
In-Reply-To: <20140825171600.GH25892@linux-mips.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ralf Baechle <ralf@linux-mips.org>, Max Filippov <jcmvbkbc@gmail.com>
Cc: linux-xtensa@linux-xtensa.org, Chris Zankel <chris@zankel.net>, Marc Gauthier <marc@cadence.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-mips@linux-mips.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>, Steven Hill <Steven.Hill@imgtec.com>

On 08/25/2014 13:16, Ralf Baechle wrote:
> On Sat, Aug 02, 2014 at 05:11:37AM +0400, Max Filippov wrote:
> 
>> this series adds mapping color control to the generic kmap code, allowing
>> architectures with aliasing VIPT cache to use high memory. There's also
>> use example of this new interface by xtensa.
> 
> I haven't actually ported this to MIPS but it certainly appears to be
> the right framework to get highmem aliases handled on MIPS, too.
> 
> Though I still consider increasing PAGE_SIZE to 16k the preferable
> solution because it will entirly do away with cache aliases.

Won't setting PAGE_SIZE to 16k break some existing userlands (o32)?  I use a
4k PAGE_SIZE because the last few times I've tried 16k or 64k, init won't
load (SIGSEGVs or such, which panicks the kernel).

-- 
Joshua Kinard
Gentoo/MIPS
kumba@gentoo.org
4096R/D25D95E3 2011-03-28

"The past tempts us, the present confuses us, the future frightens us.  And
our lives slip away, moment by moment, lost in that vast, terrible in-between."

--Emperor Turhan, Centauri Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
