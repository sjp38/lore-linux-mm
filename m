Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 7F06F6B0070
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 11:31:00 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <83884ff2-1a06-4d9c-a7eb-c53ab0cbb6b1@default>
Date: Wed, 20 Jun 2012 08:30:35 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: help converting zcache from sysfs to debugfs?
References: <6b8ff49a-a5aa-4b9b-9425-c9bc7df35a34@default>
 <4FE1DFDC.1010105@linux.vnet.ibm.com>
In-Reply-To: <4FE1DFDC.1010105@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Nitin Gupta <ngupta@vflare.org>, Konrad Wilk <konrad.wilk@oracle.com>, Sasha Levin <levinsasha928@gmail.com>

> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> Subject: Re: help converting zcache from sysfs to debugfs?
>=20
> Something like this (untested):

Nice!  I also need a set for atomic_long_t.

But forgive me if I nearly have a heart attack as I
contemplate another chicken-and-egg scenario trying
to get debugfs-support-for-atomics upstream before
zcache code that depends on it.

Maybe I'm a leetle bit over-sensitized to dependencies...
or maybe not enough ;-)

Anyway, I will probably use the ugly code and add a
comment that says the code can be made cleaner when
debugfs supports atomics.

Thanks!
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
