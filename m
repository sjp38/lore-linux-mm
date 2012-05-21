Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id C3FD66B0082
	for <linux-mm@kvack.org>; Mon, 21 May 2012 09:39:38 -0400 (EDT)
From: Satoru Moriya <satoru.moriya@hds.com>
Date: Mon, 21 May 2012 09:39:29 -0400
Subject: RE: [RFC][PATCH] avoid swapping out with swappiness==0
Message-ID: <65795E11DBF1E645A09CEC7EAEE94B9C015955EED7@USINDEVS02.corp.hds.com>
References: <65795E11DBF1E645A09CEC7EAEE94B9CB951A45F@USINDEVS02.corp.hds.com>
 <20120424082019.GA18395@alpha.arachsys.com>
 <65795E11DBF1E645A09CEC7EAEE94B9C014649EC4D@USINDEVS02.corp.hds.com>
 <20120426142643.GA18863@alpha.arachsys.com>
 <CAHGf_=pcmFrWjfW3eQi_AiemQEm_e=gBZ24s+Hiythmd=J9EUQ@mail.gmail.com>
 <4FA82C11.2030805@redhat.com> <20120521071226.GJ29495@alpha.arachsys.com>
In-Reply-To: <20120521071226.GJ29495@alpha.arachsys.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Davies <richard.davies@elastichosts.com>, Rik van Riel <riel@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Jerome Marchand <jmarchan@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "lwoodman@redhat.com" <lwoodman@redhat.com>, "dle-develop@lists.sourceforge.net" <dle-develop@lists.sourceforge.net>, Seiji Aguchi <seiji.aguchi@hds.com>, Minchan Kim <minchan.kim@gmail.com>

Hi Richard,

On 05/21/2012 03:12 AM, Richard Davies wrote:
> Now that 3.4 is out with Rik's fixes, I'm keen to start testing with=20
> and without this extra patch.
>=20
> Satoru - should I just apply your original patch (most likely), or do=20
> you need to update for the final released kernel?

Thank you for testing!
I believe you can apply the patch without any updates.

Regards,
Satoru

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
