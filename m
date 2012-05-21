Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 026C36B0044
	for <linux-mm@kvack.org>; Mon, 21 May 2012 11:04:07 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <ee168801-3f7e-49ec-9a6e-14b6a4bc6a5f@default>
Date: Mon, 21 May 2012 08:04:00 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH] zsmalloc: use unsigned long instead of void *
References: <1337567013-4741-1-git-send-email-minchan@kernel.org>
 <4FBA4EE2.8050308@linux.vnet.ibm.com>
In-Reply-To: <4FBA4EE2.8050308@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>

> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> Subject: Re: [PATCH] zsmalloc: use unsigned long instead of void *
>=20
> On 05/20/2012 09:23 PM, Minchan Kim wrote:
>=20
> > We should use unsigned long as handle instead of void * to avoid any
> > confusion. Without this, users may just treat zs_malloc return value as
> > a pointer and try to deference it.
>=20
> I wouldn't have agreed with you about the need for this change as people
> should understand a void * to be the address of some data with unknown
> structure.
>=20
> However, I recently discussed with Dan regarding his RAMster project
> where he assumed that the void * would be an address, and as such,
> 4-byte aligned.  So he has masked two bits into the two LSBs of the
> handle for RAMster, which doesn't work with zsmalloc since the handle is
> not an address.
>=20
> So really we do need to convey as explicitly as possible to the user
> that the handle is an _opaque_ value about which no assumption can be mad=
e.

Someone once said: "Opaque is a computer science term and has no
meaning in system software and computer engineering."  ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
