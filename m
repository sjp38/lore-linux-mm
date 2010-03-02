Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id EAAAB6B0078
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 09:19:41 -0500 (EST)
Subject: Re: [RFC] nfs: use 4*rsize readahead size
From: Trond Myklebust <Trond.Myklebust@netapp.com>
In-Reply-To: <20100302031021.GA14267@localhost>
References: <20100224024100.GA17048@localhost>
	 <20100224032934.GF16175@discord.disaster>
	 <20100224041822.GB27459@localhost>
	 <20100224052215.GH16175@discord.disaster> <20100224061247.GA8421@localhost>
	 <20100224073940.GJ16175@discord.disaster> <20100226074916.GA8545@localhost>
	 <20100302031021.GA14267@localhost>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 02 Mar 2010 09:19:23 -0500
Message-ID: <1267539563.3099.43.camel@localhost.localdomain>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Dave Chinner <david@fromorbit.com>, "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2010-03-02 at 11:10 +0800, Wu Fengguang wrote:=20
> Dave,
>=20
> Here is one more test on a big ext4 disk file:
>=20
> 	   16k	39.7 MB/s
> 	   32k	54.3 MB/s
> 	   64k	63.6 MB/s
> 	  128k	72.6 MB/s
> 	  256k	71.7 MB/s
> rsize =3D=3D> 512k  71.7 MB/s
> 	 1024k	72.2 MB/s
> 	 2048k	71.0 MB/s
> 	 4096k	73.0 MB/s
> 	 8192k	74.3 MB/s
> 	16384k	74.5 MB/s
>=20
> It shows that >=3D128k client side readahead is enough for single disk
> case :) As for RAID configurations, I guess big server side readahead
> should be enough.

There are lots of people who would like to use NFS on their company WAN,
where you typically have high bandwidths (up to 10GigE), but often a
high latency too (due to geographical dispersion).
My ping latency from here to a typical server in NetApp's Bangalore
office is ~ 312ms. I read your test results with 10ms delays, but have
you tested with higher than that?

Cheers
  Trond

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
