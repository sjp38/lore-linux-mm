Message-ID: <413FAE0E.40304@kolivas.org>
Date: Thu, 09 Sep 2004 11:12:46 +1000
From: Con Kolivas <kernel@kolivas.org>
MIME-Version: 1.0
Subject: Re: swapping and the value of /proc/sys/vm/swappiness
References: <413CB661.6030303@sgi.com> <cone.1094512172.450816.6110.502@pc.kolivas.org> <20040906162740.54a5d6c9.akpm@osdl.org> <cone.1094513660.210107.6110.502@pc.kolivas.org> <20040907000304.GA8083@logos.cnet> <413D8FB2.1060705@cyberone.com.au> <413D93EF.80305@kolivas.org> <20040908164549.GA4284@logos.cnet>
In-Reply-To: <20040908164549.GA4284@logos.cnet>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigF4309F1C92B485643BC3288A"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Nick Piggin <piggin@cyberone.com.au>, Andrew Morton <akpm@osdl.org>, raybry@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com, mbligh@aracnet.com
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigF4309F1C92B485643BC3288A
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Marcelo Tosatti wrote:
> On Tue, Sep 07, 2004 at 08:56:47PM +1000, Con Kolivas wrote:
> 
>>Nick Piggin wrote:
>>
>>>
>>>Marcelo Tosatti wrote:
>>>
>>>
>>>>Hi kernel fellows,
>>>>
>>>>I volunteer. I'll try something tomorrow to compare swappiness of 
>>>>older kernels like  2.6.5 and 2.6.6, which were fine on SGI's Altix 
>>>>tests, up to current newer kernels (on small memory boxes of course).
>>>>
>>>
>>>Hi Marcelo,
>>>
>>>Just a suggestion - I'd look at the thrashing control patch first.
>>>I bet that's the cause.
>>
>>Good point!
>>
>>I recall one of my users found his workload which often hit swap lightly 
>>was swapping much heavier and his performance dropped dramatically until 
>>I stopped including the swap thrash control patch. I informed Rik about 
>>it some time back so I'm not sure if he addressed it in the meantime.
> 
> 
> Swap thrashing code doesnt affect anything, at least on my simple contained test.
> With the same test, the amount of swapped out memory with 2.6.6/2.6.7 is 100-150MB,
>  while 2.6.8/2.6.9-mm* swaps out around 250MB.
> 
> I tried 2.6.7's "vmscan.c" on 2.6.8 without noticeable difference, I wonder why. 
> 
> What I've noticed before with the swap token code is total crap interactivity 
> when memory hog is running. Which doesnt happen without it.
> 
> Con, I've seen your hard swappiness patch, why do you remove the current
> swap_tendency calculation? Can you give us some insight into it? 

Sure. It was painfully simple. The swap tendency worked basically the 
same but did not take into account distress. ie It made the "swappiness" 
knob purely dependant on mapped ratio. For whatever reason, if the 
swappiness value is the same in later kernels but swaps more, there is 
more "distress" meaning we are priority scanning much more aggressively.

Cheers,
Con

--------------enigF4309F1C92B485643BC3288A
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://enigmail.mozdev.org

iD8DBQFBP64QZUg7+tp6mRURAqmvAJ9PbRDWLU5cnsf7ObL/pSj9u9HREQCfShJG
Nyfmx+LOP5hiubDiMmmIu/4=
=9MXI
-----END PGP SIGNATURE-----

--------------enigF4309F1C92B485643BC3288A--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
