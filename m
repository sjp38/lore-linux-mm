Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 2A0946B0044
	for <linux-mm@kvack.org>; Tue, 24 Apr 2012 18:14:59 -0400 (EDT)
From: Satoru Moriya <satoru.moriya@hds.com>
Date: Tue, 24 Apr 2012 18:14:37 -0400
Subject: RE: [RFC][PATCH] avoid swapping out with swappiness==0
Message-ID: <65795E11DBF1E645A09CEC7EAEE94B9C014649EC4D@USINDEVS02.corp.hds.com>
References: <65795E11DBF1E645A09CEC7EAEE94B9CB951A45F@USINDEVS02.corp.hds.com>
 <20120424082019.GA18395@alpha.arachsys.com>
In-Reply-To: <20120424082019.GA18395@alpha.arachsys.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Davies <richard@arachsys.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Jerome Marchand <jmarchan@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "jweiner@redhat.com" <jweiner@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "riel@redhat.com" <riel@redhat.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, "shaohua.li@intel.com" <shaohua.li@intel.com>, "dle-develop@lists.sourceforge.net" <dle-develop@lists.sourceforge.net>, Seiji Aguchi <seiji.aguchi@hds.com>, Minchan Kim <minchan.kim@gmail.com>

On 04/24/2012 04:20 AM, Richard Davies wrote:
>=20
> I have run into problems with heavy swapping with swappiness=3D=3D0 and=20
> was pointed to this thread (=20
> http://marc.info/?l=3Dlinux-mm&m=3D133522782307215 )

Did you test this patch with your workload?
If yes, how did it come out?

> I strongly believe that Linux should have a way to turn off swapping=20
> unless absolutely necessary. This means that users like us can run=20
> with swap present for emergency use, rather than having to disable it=20
> because of the side effects.

Agreed. That is why I proposed the patch.

> Personally, I feel that swappiness=3D=3D0 should have this (intuitive)=20
> meaning, and that people running RHEL5 are extremely unlikely to run=20
> 3.5 kernels(!)
>=20
> However, swappiness=3D=3D-1 or some other hack is definitely better than=
=20
> no patch.


Regards,
Satoru

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
