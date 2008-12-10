From: Paul Menage <menage@google.com>
Subject: Re: [RFC][PATCH 1/6] memcg: fix pre_destory handler
Date: Wed, 10 Dec 2008 10:26:28 -0800
Message-ID: <6599ad830812101026g7d2813acvec7cdb3e0321f780@mail.gmail.com>
References: <6599ad830812100240g5e549a5cqe29cbea736788865@mail.gmail.com>
	 <29741.10.75.179.61.1228908581.squirrel@webmail-b.css.fujitsu.com>
	 <20081210132559.GF25467@balbir.in.ibm.com>
	 <20081210224758.46abbd59.d-nishimura@mtf.biglobe.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <owner-linux-mm@kvack.org>
Received: from spaceape10.eur.corp.google.com (spaceape10.eur.corp.google.com [172.28.16.144])
	by smtp-out.google.com with ESMTP id mBAIQU4x006606
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 10:26:31 -0800
Received: from qw-out-2122.google.com (qwh8.prod.google.com [10.241.194.200])
	by spaceape10.eur.corp.google.com with ESMTP id mBAIQSHZ031169
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 10:26:29 -0800
Received: by qw-out-2122.google.com with SMTP id 8so369697qwh.63
        for <linux-mm@kvack.org>; Wed, 10 Dec 2008 10:26:28 -0800 (PST)
In-Reply-To: <20081210224758.46abbd59.d-nishimura@mtf.biglobe.ne.jp>
Sender: owner-linux-mm@kvack.org
To: nishimura@mxp.nes.nec.co.jp
Cc: balbir@linux.vnet.ibm.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, d-nishimura@mtf.biglobe.ne.jp
List-Id: linux-mm.kvack.org

On Wed, Dec 10, 2008 at 5:47 AM, Daisuke Nishimura
<d-nishimura@mtf.biglobe.ne.jp> wrote:
> Hmm.. but doesn't per-hierarchy-mutex solve the problem if memory and cpuset
> mounted on the same hierarchy ?
>

It's not a per-hierarchy mutex - it's a per-subsystem lock against
changes on that subsystem's hierarchy. So each subsystem just has to
take its own lock, rather than a global or per-hierarchy lock. The
cgroups code takes care of acquiring the multiple locks in a safe
order when necessary.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
