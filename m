Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id E8E9B6B0002
	for <linux-mm@kvack.org>; Wed,  6 Feb 2013 05:10:54 -0500 (EST)
Message-ID: <5112240C.1010105@cn.fujitsu.com>
Date: Wed, 06 Feb 2013 17:36:12 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 6/7] net: change type of netns_ipvs->sysctl_sync_qlen_max
References: <alpine.LFD.2.00.1302061115590.1664@ja.ssi.bg>
In-Reply-To: <alpine.LFD.2.00.1302061115590.1664@ja.ssi.bg>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Julian Anastasov <ja@ssi.bg>
Cc: Andrew Morton <akpm@linux-foundation.org>, horms@verge.net.au, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, kamezawa.hiroyu@jp.fujitsu.com, minchan@kernel.org, mgorman@suse.de

=E4=BA=8E 2013=E5=B9=B402=E6=9C=8806=E6=97=A5 17:29, Julian Anastasov =E5=
=86=99=E9=81=93:
>=20
> 	Hello,
>=20
> 	Sorry that I'm writing a private email but I
> deleted your original message by mistake. Your change
> of the sysctl=5Fsync=5Fqlen=5Fmax from int to long is may be
> not enough.
>=20
> 	net/netfilter/ipvs/ip=5Fvs=5Fctl.c contains
> proc var "sync=5Fqlen=5Fmax" that should be changed to
> sizeof(unsigned long) and updated with proc=5Fdoulongvec=5Fminmax.
>=20

Thanks for pointing this. I will update this in patch v2.

Thanks
Zhang Yanfei


=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
