Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id D238C6B004D
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 09:48:34 -0500 (EST)
From: <leonid.moiseichuk@nokia.com>
Subject: RE: [PATCH v2 1/2] Making si_swapinfo exportable
Date: Wed, 18 Jan 2012 14:47:47 +0000
Message-ID: <84FF21A720B0874AA94B46D76DB98269045599D8@008-AM1MPN1-003.mgdnok.nokia.com>
References: <cover.1326803859.git.leonid.moiseichuk@nokia.com>
 <56cc3c5d40a8653b7d9bef856ff02d909b98f36f.1326803859.git.leonid.moiseichuk@nokia.com>
 <CAOJsxLHfHHrFyhfkSe8mbsnJHBkgKtksCZZDwN6K3d7KJqfzkQ@mail.gmail.com>
 <20120118140904.GB13817@suse.de>
In-Reply-To: <20120118140904.GB13817@suse.de>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@suse.de, penberg@kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cesarb@cesarb.net, kamezawa.hiroyu@jp.fujitsu.com, emunson@mgebm.net, aarcange@redhat.com, riel@redhat.com, mel@csn.ul.ie, rientjes@google.com, dima@android.com, rebecca@android.com, san@google.com, akpm@linux-foundation.org, vesa.jaaskelainen@nokia.com

> -----Original Message-----
> From: ext Greg KH [mailto:gregkh@suse.de]
> Sent: 18 January, 2012 16:09
...

> > > +EXPORT_SYMBOL(si_swapinfo);
>=20
> EXPORT_SYMBOL_GPL() perhaps?

I followed si_meminfo which is uses EXPORT_SYMBOL.=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
