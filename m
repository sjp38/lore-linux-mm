Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-gg0-f171.google.com (mail-gg0-f171.google.com [209.85.161.171])
	by kanga.kvack.org (Postfix) with ESMTP id 074226B0037
	for <linux-mm@kvack.org>; Thu, 23 Jan 2014 00:21:25 -0500 (EST)
Received: by mail-gg0-f171.google.com with SMTP id q4so192348ggn.16
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 21:21:25 -0800 (PST)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id v1si13956064yhg.124.2014.01.22.21.21.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 22 Jan 2014 21:21:24 -0800 (PST)
Date: Thu, 23 Jan 2014 00:21:18 -0500
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] really large storage sectors - going
 beyond 4096 bytes
Message-ID: <20140123052118.GA6853@thunk.org>
References: <1390411300.2372.33.camel@dabdike.int.hansenpartnership.com>
 <1390413819.1198.20.camel@ret.masoncoding.com>
 <1390414439.2372.53.camel@dabdike.int.hansenpartnership.com>
 <52E00B28.3060609@redhat.com>
 <1390415703.2372.62.camel@dabdike.int.hansenpartnership.com>
 <52E0106B.5010604@redhat.com>
 <1390419019.2372.89.camel@dabdike.int.hansenpartnership.com>
 <20140122115002.bb5d01dee836b567a7aad157@linux-foundation.org>
 <1390421691.1198.43.camel@ret.masoncoding.com>
 <alpine.DEB.2.02.1401221836330.13577@nftneq.ynat.uz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1401221836330.13577@nftneq.ynat.uz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Lang <david@lang.hm>
Cc: Chris Mason <clm@fb.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-ide@vger.kernel.org" <linux-ide@vger.kernel.org>, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>, "rwheeler@redhat.com" <rwheeler@redhat.com>, "James.Bottomley@hansenpartnership.com" <James.Bottomley@hansenpartnership.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "mgorman@suse.de" <mgorman@suse.de>

On Wed, Jan 22, 2014 at 06:46:11PM -0800, David Lang wrote:
> It's extremely unlikely that drive manufacturers will produce drives
> that won't work with any existing OS, so they are going to support
> smaller writes in firmware. If they don't, they won't be able to
> sell their drives to anyone running existing software. Given the
> Enterprise software upgrade cycle compared to the expanding storage
> needs, whatever they ship will have to work on OS and firmware
> releases that happened several years ago.

I've been talking to a number of HDD vendors, and while most of the
discussions has been about SMR, the topic of 64k sectors did come up
recently.  In the opinion of at least one drive vendor, the pressure
or 64k sectors will start increasing (roughly paraphrasing that
vendor's engineer, "it's a matter of physics"), and it might not be
surprising that in 2 or 3 years, we might start seing drives with 64k
sectors.  Like with 4k sector drives, it's likely that at least
initial said drives will have an emulation mode where sub-64k writes
will require a read-modify-write cycle.

What I told that vendor was that if this were the case, he should
seriously consider submitting a topic proposal to the LSF/MM, since if
he wants those drives to be well supported, we need to start thinking
about what changes might be necessary at the VM and FS layers now.  So
hopefully we'll see a topic proposal from that HDD vendor in the next
couple of days.

The bottom line is that I'm pretty well convinced that like SMR
drives, 64k sector drives will be coming, and it's not something we
can duck.  It might not come as quickly as the HDD vendor community
might like --- I remember attending an IDEMA conference in 2008 where
they confidently predicted that 4k sector drives would be the default
in 2 years, and it took a wee bit longer than that.  But nevertheless,
looking at the most likely roadmap and trajectory of hard drive
technology, these are two things that will very likely be coming down
the pike, and it would be best if we start thinking about how to
engage with these changes constructively sooner rather than putting it
off and then getting caught behind the eight-ball later.

Cheers,

						- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
