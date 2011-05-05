Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B7231900001
	for <linux-mm@kvack.org>; Wed,  4 May 2011 23:38:10 -0400 (EDT)
From: Satoru Moriya <satoru.moriya@hds.com>
Date: Wed, 4 May 2011 23:37:46 -0400
Subject: RE: [PATCH] getdelays: show average CPU/IO/SWAP/RECLAIM delays
Message-ID: <65795E11DBF1E645A09CEC7EAEE94B9C3DF8133D@USINDEVS02.corp.hds.com>
References: <20110502140257.GA12780@localhost>
In-Reply-To: <20110502140257.GA12780@localhost>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mel@linux.vnet.ibm.com>, Dave Young <hidave.darkstar@gmail.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Dave Chinner <david@fromorbit.com>, David Rientjes <rientjes@google.com>

On 05/02/2011 10:02 AM, Wu Fengguang wrote:=20
> I find it very handy to show the average delays in milliseconds.
>=20
> Example output (on 100 concurrent dd reading sparse files):
>=20
> CPU             count     real total  virtual total    delay total  delay=
 average
>                   986     3223509952     3207643301    38863410579       =
  39.415ms
> IO              count    delay total  delay average
>                     0              0              0ms
> SWAP            count    delay total  delay average
>                     0              0              0ms
> RECLAIM         count    delay total  delay average
>                  1059     5131834899              4ms
> dd: read=3D0, write=3D0, cancelled_write=3D0
>=20
> CC: Mel Gorman <mel@linux.vnet.ibm.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>

This is useful for me.

Reviewed-by: Satoru Moriya <satoru.moriya@hds.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
