Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 0B7C16B0005
	for <linux-mm@kvack.org>; Wed,  6 Feb 2013 20:51:59 -0500 (EST)
Message-ID: <5113085E.4030104@cn.fujitsu.com>
Date: Thu, 07 Feb 2013 09:50:22 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 6/7] net: change type of netns_ipvs->sysctl_sync_qlen_max
References: <alpine.LFD.2.00.1302061115590.1664@ja.ssi.bg> <5112240C.1010105@cn.fujitsu.com> <20130207010914.GA9070@verge.net.au>
In-Reply-To: <20130207010914.GA9070@verge.net.au>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Horman <horms@verge.net.au>
Cc: Julian Anastasov <ja@ssi.bg>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, kamezawa.hiroyu@jp.fujitsu.com, minchan@kernel.org, mgorman@suse.de

=E4=BA=8E 2013=E5=B9=B402=E6=9C=8807=E6=97=A5 09:09, Simon Horman =E5=86=99=
=E9=81=93:
> On Wed, Feb 06, 2013 at 05:36:12PM +0800, Zhang Yanfei wrote:
>> =E4=BA=8E 2013=E5=B9=B402=E6=9C=8806=E6=97=A5 17:29, Julian Anastasov =
=E5=86=99=E9=81=93:
>>>
>>> 	Hello,
>>>
>>> 	Sorry that I'm writing a private email but I
>>> deleted your original message by mistake. Your change
>>> of the sysctl=5Fsync=5Fqlen=5Fmax from int to long is may be
>>> not enough.
>>>
>>> 	net/netfilter/ipvs/ip=5Fvs=5Fctl.c contains
>>> proc var "sync=5Fqlen=5Fmax" that should be changed to
>>> sizeof(unsigned long) and updated with proc=5Fdoulongvec=5Fminmax.
>>>
>>
>> Thanks for pointing this. I will update this in patch v2.
>=20
> Hi Zhang,
>=20
> Thanks for helping to keep IPVS up to date.
>=20
> It seems to me that include/net/ip=5Fvs.h:sysctl=5Fsync=5Fqlen=5Fmax()
> and its call site, net/netfilter/ipvs/ip=5Fvs=5Fsync.c:sb=5Fqueue=5Ftail()
> may also need to be updated.
>=20
> Could you look at including that in v2 too?

OK. I will update it.

Thanks
Zhang

=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
