Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 5726E6B0002
	for <linux-mm@kvack.org>; Sat, 16 Mar 2013 14:24:53 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <6041f181-67b1-4f71-bd5c-cfb48f1ddfb0@default>
Date: Sat, 16 Mar 2013 11:24:20 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH v2 1/4] introduce zero filled pages handler
References: <1363255697-19674-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1363255697-19674-2-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130316130302.GA5987@konrad-lan.dumpdata.com>
In-Reply-To: <20130316130302.GA5987@konrad-lan.dumpdata.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad@darnok.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> From: Konrad Rzeszutek Wilk [mailto:konrad@darnok.org]
> Subject: Re: [PATCH v2 1/4] introduce zero filled pages handler
>=20
> > +
> > +=09for (pos =3D 0; pos < PAGE_SIZE / sizeof(*page); pos++) {
> > +=09=09if (page[pos])
> > +=09=09=09return false;
>=20
> Perhaps allocate a static page filled with zeros and just do memcmp?

That seems like a bad idea.  Why compare two different
memory locations when comparing one memory location
to a register will do?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
