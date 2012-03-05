Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 6EA976B002C
	for <linux-mm@kvack.org>; Mon,  5 Mar 2012 16:48:32 -0500 (EST)
From: Satoru Moriya <satoru.moriya@hds.com>
Date: Mon, 5 Mar 2012 16:38:14 -0500
Subject: RE: [RFC][PATCH] avoid swapping out with swappiness==0
Message-ID: <65795E11DBF1E645A09CEC7EAEE94B9CB9456775@USINDEVS02.corp.hds.com>
References: <65795E11DBF1E645A09CEC7EAEE94B9CB9455FE2@USINDEVS02.corp.hds.com>
 <20120304065759.GA7824@barrios>
In-Reply-To: <20120304065759.GA7824@barrios>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, "shaohua.li@intel.com" <shaohua.li@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "dle-develop@lists.sourceforge.net" <dle-develop@lists.sourceforge.net>, Seiji Aguchi <seiji.aguchi@hds.com>

Hi Minchan,

Thank you for reviewing.

On 03/04/2012 01:57 AM, Minchan Kim wrote:
> On Fri, Mar 02, 2012 at 12:36:40PM -0500, Satoru Moriya wrote:
>=20
> I agree this feature but current code is rather ugly on readbility.

I agree with you.

> Hillf's version looks to be much clean refactoring so after we merge=20
> your patch, we can tidy it up with Hillf's patch.

Thanks. No problem.

Regards,
Satoru

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
