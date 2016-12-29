Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 018776B0069
	for <linux-mm@kvack.org>; Thu, 29 Dec 2016 12:27:46 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id f188so1165321670pgc.1
        for <linux-mm@kvack.org>; Thu, 29 Dec 2016 09:27:45 -0800 (PST)
Received: from anholt.net (anholt.net. [50.246.234.109])
        by mx.google.com with ESMTP id l78si54179812pfg.206.2016.12.29.09.27.44
        for <linux-mm@kvack.org>;
        Thu, 29 Dec 2016 09:27:44 -0800 (PST)
From: Eric Anholt <eric@anholt.net>
Subject: Re: [PATCH] mm: Drop "PFNs busy" printk in an expected path.
In-Reply-To: <20161229091256.GF29208@dhcp22.suse.cz>
References: <20161229023131.506-1-eric@anholt.net> <20161229091256.GF29208@dhcp22.suse.cz>
Date: Thu, 29 Dec 2016 09:27:42 -0800
Message-ID: <87wpeitzld.fsf@eliezer.anholt.net>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-stable <stable@vger.kernel.org>, "Robin H. Johnson" <robbat2@orbis-terrarum.net>, Michal Nazarewicz <mina86@mina86.com>, Vlastimil Babka <vbabka@suse.cz>, Marek Szyprowski <m.szyprowski@samsung.com>

--=-=-=
Content-Type: text/plain

Michal Hocko <mhocko@kernel.org> writes:

> This has been already brought up
> http://lkml.kernel.org/r/20161130092239.GD18437@dhcp22.suse.cz and there
> was a proposed patch for that which ratelimited the output
> http://lkml.kernel.org/r/20161130132848.GG18432@dhcp22.suse.cz resp.
> http://lkml.kernel.org/r/robbat2-20161130T195244-998539995Z@orbis-terrarum.net
>
> then the email thread just died out because the issue turned out to be a
> configuration issue. Michal indicated that the message might be useful
> so dropping it completely seems like a bad idea. I do agree that
> something has to be done about that though. Can we reconsider the
> ratelimit thing?

I agree that the rate of the message has gone up during 4.9 -- it used
to be a few per second.  However, if this is an expected path during
normal operation, we shouldn't be clogging dmesg with it at all.  So,
I'd rather we go with this patch, that is unless the KERN_DEBUG in your
ratelimit patch would keep it out of journald as well (un-ratelimited,
journald was eating 10% of a CPU processing the message, and I'd rather
it not be getting logged at all).

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCgAdFiEE/JuuFDWp9/ZkuCBXtdYpNtH8nugFAlhlR44ACgkQtdYpNtH8
nuiJGBAApHDO41sS1UPZnr48HMD1xcfrxDwS8R2I97vTy8azBnwhonv9Vitv+7Kk
hyvnPEi+EJ+XDsVgw7c/4GraU/CxOTlu4fOCLPDHzyyXjH2FPyMtPrUvTVsx44pZ
SS5byt9vvZxgN+suxte8ursNcTEGGeDZ6hve6w47KSSQZJ1fxn35cIhrsqwuOeXB
MlokpuTvyWpQ4Kup3MownB+YxyKPuYKvue8RPap90cEoe0N7NU/cBAZQQ1nO65kR
ngL2g4i8Ho9YtLlnLOF8fUXvBdpKNvnPRo+ER4b3kLMZOkILizd4Zfvz17Z1ArgD
ybFLCOFKHtWty7PvD5AtC2v2B5JX9JBO5cmWMACpXmLJ1hNCQrwecx/8fT/FY+NF
UjNB4VkPgK8Qt55+JjwiYvF7aRz4FUVHioNophUYdO7A6BONul3zAlSSaLLtb5HZ
bjA98xRwWrTUdhtPH/7VaglI1s27lv1ZVdyWImW5wgOYoBz0dwBZz6B2T29iijlw
dWqBfFh+hfQ9UYSN2uRwcnBZWvMKKYDsAq8ae5exZs6TuM9O/7ubyE2IdnzGRk95
wys4IQ7eOA9t+f8XlaLpH56uj4VKgUsoSAqO4aOKTNhAqbKsJIoUVjZp9jyamjNt
BOYg6v8k+L2N8qW/VZZxKBoyaC0aDNKO15u5oFIobCQPZgu4Lzk=
=yK3q
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
