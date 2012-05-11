Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 11C6A8D0001
	for <linux-mm@kvack.org>; Fri, 11 May 2012 12:23:38 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <1ff67ec4-7dd0-49c8-9be2-e927f58e6472@default>
Date: Fri, 11 May 2012 09:23:12 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH] ramster: switch over to zsmalloc and crypto interface
References: <1336676781-8571-1-git-send-email-dan.magenheimer@oracle.com>
 <20120510192836.GA17750@jak-linux.org>
In-Reply-To: <20120510192836.GA17750@jak-linux.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Julian Andres Klode <jak@jak-linux.org>, gregkh@linuxfoundation.org
Cc: devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, Konrad Wilk <konrad.wilk@oracle.com>, sjenning@linux.vnet.ibm.com

> From: Julian Andres Klode [mailto:jak@jak-linux.org]
> Sent: Thursday, May 10, 2012 1:29 PM
> To: Dan Magenheimer
> Cc: devel@driverdev.osuosl.org; linux-kernel@vger.kernel.org; gregkh@linu=
xfoundation.org; linux-
> mm@kvack.org; ngupta@vflare.org; Konrad Wilk; sjenning@linux.vnet.ibm.com
> Subject: Re: [PATCH] ramster: switch over to zsmalloc and crypto interfac=
e
>=20
> On Thu, May 10, 2012 at 12:06:21PM -0700, Dan Magenheimer wrote:
> > RAMster does many zcache-like things.  In order to avoid major
> > merge conflicts at 3.4, ramster used lzo1x directly for compression
> > and retained a local copy of xvmalloc, while zcache moved to the
> > new zsmalloc allocator and the crypto API.
> >
> > This patch moves ramster forward to use zsmalloc and crypto.
> >
> > Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com
>=20
> Nothing important, but the right ">" is missing here.

Oops!  Cut-and-paste error!  Thanks for noticing Julian!

Greg, do you need me to resubmit with the missing '>'?

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
