Message-ID: <413D93EF.80305@kolivas.org>
Date: Tue, 07 Sep 2004 20:56:47 +1000
From: Con Kolivas <kernel@kolivas.org>
MIME-Version: 1.0
Subject: Re: swapping and the value of /proc/sys/vm/swappiness
References: <413CB661.6030303@sgi.com> <cone.1094512172.450816.6110.502@pc.kolivas.org> <20040906162740.54a5d6c9.akpm@osdl.org> <cone.1094513660.210107.6110.502@pc.kolivas.org> <20040907000304.GA8083@logos.cnet> <413D8FB2.1060705@cyberone.com.au>
In-Reply-To: <413D8FB2.1060705@cyberone.com.au>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig605B5C3A5E688693378648F1"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Andrew Morton <akpm@osdl.org>, raybry@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com, mbligh@aracnet.com
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig605B5C3A5E688693378648F1
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Nick Piggin wrote:
> 
> 
> Marcelo Tosatti wrote:
> 
>>
>> Hi kernel fellows,
>>
>> I volunteer. I'll try something tomorrow to compare swappiness of 
>> older kernels like  2.6.5 and 2.6.6, which were fine on SGI's Altix 
>> tests, up to current newer kernels (on small memory boxes of course).
>>
> 
> Hi Marcelo,
> 
> Just a suggestion - I'd look at the thrashing control patch first.
> I bet that's the cause.

Good point!

I recall one of my users found his workload which often hit swap lightly 
was swapping much heavier and his performance dropped dramatically until 
I stopped including the swap thrash control patch. I informed Rik about 
it some time back so I'm not sure if he addressed it in the meantime.

Cheers,
Con

--------------enig605B5C3A5E688693378648F1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://enigmail.mozdev.org

iD8DBQFBPZPvZUg7+tp6mRURAt75AJoDO2MiPLxjsMuJ2LscDLluet48YQCeJeD4
5Wc+3JbjKC2DND3eCgBd2Ps=
=rNxM
-----END PGP SIGNATURE-----

--------------enig605B5C3A5E688693378648F1--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
