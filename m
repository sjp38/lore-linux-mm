Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id C449D6B00F8
	for <linux-mm@kvack.org>; Wed,  9 May 2012 02:24:57 -0400 (EDT)
Received: by vbbey12 with SMTP id ey12so78859vbb.14
        for <linux-mm@kvack.org>; Tue, 08 May 2012 23:24:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1203191339470.27517@chino.kir.corp.google.com>
References: <4F6743C2.3090906@parallels.com>
	<alpine.DEB.2.00.1203191028160.19189@router.home>
	<alpine.DEB.2.00.1203191339470.27517@chino.kir.corp.google.com>
Date: Wed, 9 May 2012 09:24:56 +0300
Message-ID: <CAOJsxLEFsT3Ef9ztPnooJF2uSwELpkf90u_1=CtbvGGbO2LOiw@mail.gmail.com>
Subject: Re: object allocation benchmark
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Christoph Lameter <cl@linux.com>, Glauber Costa <glommer@parallels.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Suleiman Souhlal <suleiman@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Mon, Mar 19, 2012 at 10:41 PM, David Rientjes <rientjes@google.com> wrot=
e:
> On Mon, 19 Mar 2012, Christoph Lameter wrote:
>
>> I have some in kernel benchmarking tools for page allocator and slab
>> allocators. But they are not really clean patches.
>>
>
> This is the latest version of your tools that I have based on 3.3. =A0Loa=
d
> the modules with insmod and it will produce an error to automatically
> unloaded (by design) and check dmesg for the results.

Anyone interested in pushing the benchmark to mainline?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
