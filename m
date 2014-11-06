Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 04DB96B00D5
	for <linux-mm@kvack.org>; Thu,  6 Nov 2014 17:56:57 -0500 (EST)
Received: by mail-wg0-f45.google.com with SMTP id x12so2393104wgg.32
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 14:56:56 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id bd10si11899296wjc.128.2014.11.06.14.56.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Nov 2014 14:56:56 -0800 (PST)
Message-ID: <545BFC86.2000006@redhat.com>
Date: Thu, 06 Nov 2014 17:56:06 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/5] lib: lockless generic and arch independent page table
 (gpt) v2.
References: <1415047353-29160-1-git-send-email-j.glisse@gmail.com> <1415047353-29160-4-git-send-email-j.glisse@gmail.com> <545BF6E0.8060001@redhat.com> <20141106224051.GA6877@gmail.com>
In-Reply-To: <20141106224051.GA6877@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 11/06/2014 05:40 PM, Jerome Glisse wrote:
> On Thu, Nov 06, 2014 at 05:32:00PM -0500, Rik van Riel wrote:

> Never a fan of preprocessor magic, but I  see why it's needed.
> 
> Acked-by: Rik van Riel <riel@redhat.com>
> 
>> v1 is not using preprocessor but has a bigger gpt struct
>> footprint and also more complex calculation for page table
>> walking due to the fact that i just rely more on runtime
>> computation than on compile time shift define through 
>> preprocessor magic.
> 
>> Given i am not a fan either of preprocessor magic if it makes you
>> feel any better i can resort to use v1, both have seen same kind
>> of testing and both are functionaly equivalent (API they expose
>> is obviously slightly different).
> 
>> I am not convince that what the computation i save using
>> preprocessor will show up in anyway as being bottleneck for hot
>> path.

I have no strong preference either way. This code is perfectly readable.

Andrew?

- -- 
All rights reversed
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJUW/yGAAoJEM553pKExN6DqcwIAJAh8mUCOuzyhqJl21qMGWu9
FwL8qEUCxxXxLuX2MFv/wbkb07+OLI8nStI5rPxk6qUdC53YV4Bc7CWfvwF4slRB
hpPVGhmNKj4e5jwP+d8/MMSd6QfGA/jaiiRw9IxasOxzYKJxtKW4wAsme+qiDy6Y
i59sGQndVUstP6Zf5ZnaKN7BkG57daQqwypktPpMf7CQxv2uN5nnErDDFzhvm8Qz
tCcKtpsdZgek7l6RPaovvRHi0kT3L67gq5oIFuS9iiHGqhmohpj2sTENafLeWUb1
zGdjy8EcxBL5H0L1/wxs3PWjyKez1q/wEZJ390+wmRaMBWl1WqbGsAZ1uZ98bd0=
=ZAbm
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
