Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 196E86B02A7
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 19:54:21 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o75NuMVs020992
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 6 Aug 2010 08:56:22 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 10B1945DE50
	for <linux-mm@kvack.org>; Fri,  6 Aug 2010 08:56:22 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id E57BC45DE4C
	for <linux-mm@kvack.org>; Fri,  6 Aug 2010 08:56:21 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 91EB21DB8015
	for <linux-mm@kvack.org>; Fri,  6 Aug 2010 08:56:21 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4594D1DB8012
	for <linux-mm@kvack.org>; Fri,  6 Aug 2010 08:56:21 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] writeback: Adding pages_dirtied and  pages_entered_writeback
In-Reply-To: <AANLkTik9AMf1pmsguB843UC9Qq6KxBcWiN_qyeiDPp1O@mail.gmail.com>
References: <20100805132433.d1d7927b.akpm@linux-foundation.org> <AANLkTik9AMf1pmsguB843UC9Qq6KxBcWiN_qyeiDPp1O@mail.gmail.com>
Message-Id: <20100806084928.31DE.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Date: Fri,  6 Aug 2010 08:56:20 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Michael Rubin <mrubin@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, jack@suse.cz, david@fromorbit.com, hch@lst.de, axboe@kernel.dk
List-ID: <linux-mm.kvack.org>

> On Thu, Aug 5, 2010 at 1:24 PM, Andrew Morton <akpm@linux-foundation.org>=
 wrote:
> > On Wed, =A04 Aug 2010 17:43:24 -0700
> > Michael Rubin <mrubin@google.com> wrote:
> > Wait. =A0These counters appear in /proc/vmstat. =A0So why create standa=
lone
> > /proc/sys/vm files as well?
>=20
> I did not know they would show up in /proc/vmstat.
>=20
> I thought it made sense to put them in /proc/sys/vm since the other
> writeback controls are there.
> but have no problems just adding them to /prov/vmstat if that makes more =
sense.

?

/proc/vmstat already have both.

cat /proc/vmstat |grep nr_dirty
cat /proc/vmstat |grep nr_writeback

Also, /sys/devices/system/node/node0/meminfo show per-node stat.

Perhaps, I'm missing your point.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
