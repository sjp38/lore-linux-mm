Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id ED3826B0006
	for <linux-mm@kvack.org>; Fri, 18 Jan 2013 15:53:43 -0500 (EST)
MIME-Version: 1.0
Message-ID: <aad182a2-a21e-4b77-88dc-db859f71ee9e@default>
Date: Fri, 18 Jan 2013 12:53:25 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH 0/5] staging: zcache: move new zcache code base from
 ramster
References: <1358443597-9845-1-git-send-email-dan.magenheimer@oracle.com>
 <20130118204617.GB4788@kroah.com>
In-Reply-To: <20130118204617.GB4788@kroah.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, Konrad Wilk <konrad.wilk@oracle.com>, sjenning@linux.vnet.ibm.com, minchan@kernel.org

> From: Greg KH [mailto:gregkh@linuxfoundation.org]
> Subject: Re: [PATCH 0/5] staging: zcache: move new zcache code base from =
ramster
>=20
> On Thu, Jan 17, 2013 at 09:26:32AM -0800, Dan Magenheimer wrote:
> > Hi Greg --
> >
> > With "old zcache" now removed, we can now move "new zcache" from its
> > temporary home (in drivers/staging/ramster) to reclaim sole possession
> > of the name "zcache".
> >
> > Note that [PATCH 2/5] will require a manual:
> >
> > # git mv drivers/staging/ramster drivers/staging/zcache
>=20
> Ick, no, use git to generate the patch with rename style, and it will
> create the tiny patch that does this which I can then apply (-M is the
> option you want to 'git format-patch').
>=20
> Care to resend this in that format so that I can apply this properly?

Will do.  You learn something new (-M) every day.

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
