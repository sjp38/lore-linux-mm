Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f52.google.com (mail-qa0-f52.google.com [209.85.216.52])
	by kanga.kvack.org (Postfix) with ESMTP id EC3506B015C
	for <linux-mm@kvack.org>; Wed, 11 Jun 2014 09:08:53 -0400 (EDT)
Received: by mail-qa0-f52.google.com with SMTP id w8so4121225qac.25
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 06:08:53 -0700 (PDT)
Received: from cdptpa-oedge-vip.email.rr.com (cdptpa-outbound-snat.email.rr.com. [107.14.166.229])
        by mx.google.com with ESMTP id c10si31391484qab.7.2014.06.11.06.08.53
        for <linux-mm@kvack.org>;
        Wed, 11 Jun 2014 06:08:53 -0700 (PDT)
Message-ID: <539854E5.1040509@ubuntu.com>
Date: Wed, 11 Jun 2014 09:08:53 -0400
From: Phillip Susi <psusi@ubuntu.com>
MIME-Version: 1.0
Subject: Re: kernelcore not working correctly
References: <53966E16.6010104@ubuntu.com> <alpine.DEB.2.02.1406101744400.32203@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1406101744400.32203@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 6/10/2014 8:45 PM, David Rientjes wrote:
| kernelcore=1G works fine for me on the latest Linus tree, it doesn't
| shrink ZONE_DMA or ZONE_DMA32 as expected.

What?  Normally ZONE_DMA32 is 4g, so if it doesn't shrink ZONE_DMA32 down to only 1g, then it isn't working.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (MingW32)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQEcBAEBAgAGBQJTmFTlAAoJEI5FoCIzSKrwAUYIAIo2w1VBPLrymmwqDI8y7L3u
OfV0vnRA2pYMxhp3Q9batbmpRjyJkBs2zbnX1D5p1VDhDaV8txy163gw3t5mDYAJ
NttF3NIA5Z7+b2DKQpHvP3xOqk4RDrn8BR61mS7nDp0F+kIpSyHbpwK8UVt2TAss
RtqaAGJBdKCfiDf175hmf8gTVyh3W5mBSO5lT3rpOvkiH3Sgg8WmNhpQefI5i0Lc
h2jE5Xj8l2C5bzVfP7MhI3Dw9AxB6KTzJy3YfzvlGlseNDHvcHQmqtqwaL4u9bnb
xj885k4jh2YK0lYtpDRPSqoeGJLAh8cjSSvrDFM5haYRDKkDFkM0Ps5eX4DSxlI=
=kZ5b
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
