Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4742BC433FF
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 15:01:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0C59F2089E
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 15:01:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="lW+W2m09"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0C59F2089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=invisiblethingslab.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 936758E0008; Tue, 30 Jul 2019 11:01:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8EE248E0001; Tue, 30 Jul 2019 11:01:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 786558E0008; Tue, 30 Jul 2019 11:01:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 560978E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 11:01:28 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id l9so58485613qtu.12
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 08:01:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=zvdSC+++bOixa8/Ggn3YSFdCsBfxtdhmukIIZhQQVgs=;
        b=ukf7msqog+n/8G++Acdtcu8ltsp+8EyhVWamKHj50rgQMTpx6aTkr8xsV4iEEy28hV
         pDfjz8zmuSjq3Az7HcldeU26/zvMYkwefmqGK9yviscKwq2O9z/BE4zkGuvSAjgEceou
         YZ5VM+5fulXfBUYbs2MBIzwCFqOYiEk2H/91hFZvmLz0RW+o/upXP47PD7lTQ+j+1tqO
         OEuZeAblKid/FCryynM37lX1Ag4tVnZll2IyFldO3na45SMnMtPvh21jKF9a9QOB6xBW
         qMyT4vlt+JeWyTGykDB5tuRI+16ULBXbX+Khi2ex+kAVs8yj3kDM5nHTwfLoa7uJoCJu
         MZhQ==
X-Gm-Message-State: APjAAAU+6KXayV4uRoKSBls6dhhFb0wY7NpIvDRi4qBz/DgKcKk8tQUC
	mpsG+bBmhNvSp66Gc1Aj15OlgMuDlG2RuSoMtwiBZVThw5AU/GQR5HkVARUUfN2kCLDdJFga0tC
	vmckyuyhRUq//Th0NClfjn8DxTWZbv/qlqJVly9UNOlK0nP7cG9GGrK7db5pH/Go=
X-Received: by 2002:ac8:3637:: with SMTP id m52mr80902276qtb.238.1564498888079;
        Tue, 30 Jul 2019 08:01:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwxM+lLbk3OJF6J/lBfpqWiMgB8uVDEXoJsZpkngpMo8LpAQcv/FMmdaOMDaeqKgn7mzkz0
X-Received: by 2002:ac8:3637:: with SMTP id m52mr80902187qtb.238.1564498887075;
        Tue, 30 Jul 2019 08:01:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564498887; cv=none;
        d=google.com; s=arc-20160816;
        b=LCiXJDLmlTRU7GsH/zhtrnkM0wRxGuNuliyyaq5DtH9ZxFdTCKFCkZNDzF7NNQYef4
         1CYdqqO+cQPsjOZ3DA79iUYQIIrs6fhWkZ1lu8qmSHmZ1Zxr2PK83ElFCxJtN9r4TAxX
         zSGy0Ry9j8ja4dmof8qGtm4u8bnHJSnfeOjB0qiay5zOGENEp1Jpk7bCEWisP13aKxdS
         d93e9JXkULcIuk5Mc6hw/W3J6nNAqU2liFTXPoYqmnV4oQNkIHpjlXa601NmwtHvq9ca
         ksKrI/PkHOwoVIPCVYqCzaBFqPw/gGxgEMZ4utJQwiUDE2vBbx6Zfw/uJnmubA+u3ilo
         F3kQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=zvdSC+++bOixa8/Ggn3YSFdCsBfxtdhmukIIZhQQVgs=;
        b=EjK99RYmEJjwAVlkQp8gHLFCPqclLhwxpFKUXr7Zzd97PKRqlkqZkPFkhL1ptQQixP
         0mA6ExfvC6/hRxpjDfIFjEdD/EY8jbm76nDFukYMZwYJ/wxLuJTHr24pTEQUNphVy7P3
         4z6vweZh6s2IkMiedf6VLeEZyy5kH+joWavsFhy9KPw5K3fBdowQ6tsM1sShgV7TaiMx
         TTkjVbDZFPoaBEW8+2+/cbln5U6QufinNQ6+40xDN6lXqzwSQjna1OwDfZS+DZNFtEtC
         SzcKbS9vhrUC379u6jSinHCT9dB91J0N9wkK+MGEanWKyy7OfOeg8CBiADpRESTxUbqs
         CrWA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm3 header.b=lW+W2m09;
       spf=neutral (google.com: 66.111.4.229 is neither permitted nor denied by best guess record for domain of marmarek@invisiblethingslab.com) smtp.mailfrom=marmarek@invisiblethingslab.com
Received: from new3-smtp.messagingengine.com (new3-smtp.messagingengine.com. [66.111.4.229])
        by mx.google.com with ESMTPS id c54si36502895qtk.245.2019.07.30.08.01.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 08:01:27 -0700 (PDT)
Received-SPF: neutral (google.com: 66.111.4.229 is neither permitted nor denied by best guess record for domain of marmarek@invisiblethingslab.com) client-ip=66.111.4.229;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm3 header.b=lW+W2m09;
       spf=neutral (google.com: 66.111.4.229 is neither permitted nor denied by best guess record for domain of marmarek@invisiblethingslab.com) smtp.mailfrom=marmarek@invisiblethingslab.com
Received: from compute7.internal (compute7.nyi.internal [10.202.2.47])
	by mailnew.nyi.internal (Postfix) with ESMTP id AEE3A1247;
	Tue, 30 Jul 2019 11:01:26 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute7.internal (MEProxy); Tue, 30 Jul 2019 11:01:26 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to:x-me-proxy
	:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm3; bh=zvdSC+
	++bOixa8/Ggn3YSFdCsBfxtdhmukIIZhQQVgs=; b=lW+W2m09RjTW3IqalZ8nAn
	FSD+/aAr7gAdc5pa7CPKW3L82lWY7dJn+6/Gr23FPNxuMJnI/xrjPU0IIP7/zb3p
	5k+VsJg2pmEKJz3azrNAGRmDONjC5kl2dyEwteYcz551n+KY+LnCKI6WFEgUYZKb
	RDblacx4JKeUWRzwShHITV1aMT5+W47beGTgZD6F3ue6a8uuhd9MRyCR7s20ZeKq
	kpA/PCcwus1ILYsOfUoAszNv0SRJdzrcnoEKaerpuRPRcGA7SfRuryzp27xAl4vp
	bZWmnZLD3LkHbMmMw3g5A6aCMdynN7tjF2buSgh3CTxBul395PTJqOtTE9DnBciQ
	==
X-ME-Sender: <xms:xVtAXeR9tmyWb7Jq50fEaB4mJnR4qwywkr4BgNzG1mH7rHpnEUx11w>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduvddrleefgdekudcutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpeffhffvuffkfhggtggujggfsehgtderredtreejnecuhfhrohhmpeforghrvghk
    ucforghrtgiihihkohifshhkihdqifpkrhgvtghkihcuoehmrghrmhgrrhgvkhesihhnvh
    hishhisghlvghthhhinhhgshhlrggsrdgtohhmqeenucfkphepledurdeihedrfeegrdef
    feenucfrrghrrghmpehmrghilhhfrhhomhepmhgrrhhmrghrvghksehinhhvihhsihgslh
    gvthhhihhnghhslhgrsgdrtghomhenucevlhhushhtvghrufhiiigvpedt
X-ME-Proxy: <xmx:xVtAXV210lSFKwmpx-PfTm8U5WmitHBoEz5HwQNjvesy9ZYtz0Osrg>
    <xmx:xVtAXZ_MOb1wHRptEn25foHXEtIqmD6mI2XiFyhIgbRk2BlqJsoGGQ>
    <xmx:xVtAXe9t3K9R8osyOcYpwdk3UUEyDI2qBoJR5QueB7AFJ7Fv3HYPJw>
    <xmx:xltAXSJtbrQmVHYJZvo0vjZM4LrE06nFs4xuqcvzmZW7QWQGN-Lqgw>
Received: from mail-itl (ip5b412221.dynamic.kabel-deutschland.de [91.65.34.33])
	by mail.messagingengine.com (Postfix) with ESMTPA id 937328005A;
	Tue, 30 Jul 2019 11:01:23 -0400 (EDT)
Date: Tue, 30 Jul 2019 17:01:19 +0200
From: Marek =?utf-8?Q?Marczykowski-G=C3=B3recki?= <marmarek@invisiblethingslab.com>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Matthew Wilcox <willy@infradead.org>,
	Michal Hocko <mhocko@suse.com>, Juergen Gross <jgross@suse.com>,
	Russell King - ARM Linux <linux@armlinux.org.uk>,
	robin.murphy@arm.com, xen-devel@lists.xenproject.org,
	linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>,
	stable@vger.kernel.org, Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [Xen-devel] [PATCH v4 8/9] xen/gntdev.c: Convert to use
 vm_map_pages()
Message-ID: <20190730150119.GS1250@mail-itl>
References: <20190215024830.GA26477@jordon-HP-15-Notebook-PC>
 <20190728180611.GA20589@mail-itl>
 <CAFqt6zaMDnpB-RuapQAyYAub1t7oSdHH_pTD=f5k-s327ZvqMA@mail.gmail.com>
 <CAFqt6zY+07JBxAVfMqb+X78mXwFOj2VBh0nbR2tGnQOP9RrNkQ@mail.gmail.com>
 <20190729133642.GQ1250@mail-itl>
 <CAFqt6zZN+6r6wYJY+f15JAjj8dY+o30w_+EWH9Vy2kUXCKSBog@mail.gmail.com>
 <bf02becc-9db0-bb78-8efc-9e25cc115237@oracle.com>
 <20190730142233.GR1250@mail-itl>
 <CAFqt6zZOymx8RH75F69exukLYcGd45xpUHkRHK8nYXpwF8co6g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="KI6XeYrntNhU1GwB"
Content-Disposition: inline
In-Reply-To: <CAFqt6zZOymx8RH75F69exukLYcGd45xpUHkRHK8nYXpwF8co6g@mail.gmail.com>
User-Agent: Mutt/1.12+29 (a621eaed) (2019-06-14)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--KI6XeYrntNhU1GwB
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jul 30, 2019 at 08:22:02PM +0530, Souptick Joarder wrote:
> On Tue, Jul 30, 2019 at 7:52 PM Marek Marczykowski-G=C3=B3recki
> <marmarek@invisiblethingslab.com> wrote:
> >
> > On Tue, Jul 30, 2019 at 10:05:42AM -0400, Boris Ostrovsky wrote:
> > > On 7/30/19 2:03 AM, Souptick Joarder wrote:
> > > > On Mon, Jul 29, 2019 at 7:06 PM Marek Marczykowski-G=C3=B3recki
> > > > <marmarek@invisiblethingslab.com> wrote:
> > > >> On Mon, Jul 29, 2019 at 02:02:54PM +0530, Souptick Joarder wrote:
> > > >>> On Mon, Jul 29, 2019 at 1:35 PM Souptick Joarder <jrdr.linux@gmai=
l.com> wrote:
> > > >>>> On Sun, Jul 28, 2019 at 11:36 PM Marek Marczykowski-G=C3=B3recki
> > > >>>> <marmarek@invisiblethingslab.com> wrote:
> > > >>>>> On Fri, Feb 15, 2019 at 08:18:31AM +0530, Souptick Joarder wrot=
e:
> > > >>>>>> Convert to use vm_map_pages() to map range of kernel
> > > >>>>>> memory to user vma.
> > > >>>>>>
> > > >>>>>> map->count is passed to vm_map_pages() and internal API
> > > >>>>>> verify map->count against count ( count =3D vma_pages(vma))
> > > >>>>>> for page array boundary overrun condition.
> > > >>>>> This commit breaks gntdev driver. If vma->vm_pgoff > 0, vm_map_=
pages
> > > >>>>> will:
> > > >>>>>  - use map->pages starting at vma->vm_pgoff instead of 0
> > > >>>> The actual code ignores vma->vm_pgoff > 0 scenario and mapped
> > > >>>> the entire map->pages[i]. Why the entire map->pages[i] needs to =
be mapped
> > > >>>> if vma->vm_pgoff > 0 (in original code) ?
> > > >> vma->vm_pgoff is used as index passed to gntdev_find_map_index. It=
's
> > > >> basically (ab)using this parameter for "which grant reference to m=
ap".
> > > >>
> > > >>>> are you referring to set vma->vm_pgoff =3D 0 irrespective of val=
ue passed
> > > >>>> from user space ? If yes, using vm_map_pages_zero() is an altern=
ate
> > > >>>> option.
> > > >> Yes, that should work.
> > > > I prefer to use vm_map_pages_zero() to resolve both the issues. Alt=
ernatively
> > > > the patch can be reverted as you suggested. Let me know you opinion=
 and wait
> > > > for feedback from others.
> > > >
> > > > Boris, would you like to give any feedback ?
> > >
> > > vm_map_pages_zero() looks good to me. Marek, does it work for you?
> >
> > Yes, replacing vm_map_pages() with vm_map_pages_zero() fixes the
> > problem for me.
>=20
> Marek, I can send a patch for the same if you are ok.
> We need to cc stable as this changes are available in 5.2.4.

Sounds good, thanks!

--=20
Best Regards,
Marek Marczykowski-G=C3=B3recki
Invisible Things Lab
A: Because it messes up the order in which people normally read text.
Q: Why is top-posting such a bad thing?

--KI6XeYrntNhU1GwB
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEEhrpukzGPukRmQqkK24/THMrX1ywFAl1AW78ACgkQ24/THMrX
1yzCXgf/RBo3QvtbZfVV9r4EG7nQccY0lAa6q3J2HQnpO7yS80HMzp40ccWa+5io
c7QEt7/NsgEzzv7Aergzv6QivV7yH18RFG+RGWN/nEMOX2qNuSHIB6UVhVFtasWU
+4MfnwFyd6qMogaOXYSQ+n9Um2IPUdhc5hqZiMLufY2As7d3ccNYvccpR/ydE7oc
LdYvyAjOwPwFlketiZ5j73iL0J4aPNqjox00ZoVAtEijnAyTzf3RB+fIUc0WtPUW
+UrEDqTkVDwbCg0NfQtsR7UI3FZmv7x5gbmXlGZkdDGFlpKSbFhZwXLpmfv5cHKt
0lP4AtlbS/Pw0vrNR4Vb3Ex6oU/+NQ==
=afZC
-----END PGP SIGNATURE-----

--KI6XeYrntNhU1GwB--

