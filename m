From: Pekka Enberg <penberg@iki.fi>
Subject: Re: randconfig build error with next-20140512, in mm/slub.c
Date: Mon, 12 May 2014 21:53:58 +0300
Message-ID: <537118C6.7050203@iki.fi>
References: <CA+r1Zhg4JzViQt=J0XBu4dRwFUZGwi52QLefkzwcwn4NUfk8Sw@mail.gmail.com> <alpine.DEB.2.10.1405121346370.30318@gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-7;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.10.1405121346370.30318@gentwo.org>
Sender: linux-next-owner@vger.kernel.org
To: Christoph Lameter <cl@linux.com>, Jim Davis <jim.epost@gmail.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, linux-next <linux-next@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, penberg@kernel.org, mpm@selenic.com, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

On 05/12/2014 09:47 PM, Christoph Lameter wrote:
> A patch was posted today for this issue.

AFAICT, it's coming from -mm. Andrew, can you pick up the fix?

> Date: Mon, 12 May 2014 09:36:30 -0300
> From: Fabio Estevam <fabio.estevam@freescale.com>
> To: akpm@linux-foundation.org
> Cc: linux-mm@kvack.org, festevam@gmail.com, Fabio Estevam
> <fabio.estevam@freescale.com>,    Christoph Lameter <cl@linux.com>, D=
avid Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>
> Subject: [PATCH] mm: slub: Place count_partial() outside CONFIG_SLUB_=
DEBUG if block
>
>
> On Mon, 12 May 2014, Jim Davis wrote:
>
>> Building with the attached random configuration file,
>>
>> mm/slub.c: In function =A1show_slab_objects=A2:
>> mm/slub.c:4361:5: error: implicit declaration of function =A1count_p=
artial=A2 [-Werr
>> or=3Dimplicit-function-declaration]
>>       x =3D count_partial(n, count_total);
>>       ^
>> cc1: some warnings being treated as errors
>> make[1]: *** [mm/slub.o] Error 1
> >
