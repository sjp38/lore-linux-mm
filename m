Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f171.google.com (mail-ob0-f171.google.com [209.85.214.171])
	by kanga.kvack.org (Postfix) with ESMTP id 4D2366B0038
	for <linux-mm@kvack.org>; Tue, 12 May 2015 05:17:23 -0400 (EDT)
Received: by obfe9 with SMTP id e9so756890obf.1
        for <linux-mm@kvack.org>; Tue, 12 May 2015 02:17:23 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id o185si8503664oib.141.2015.05.12.02.17.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 12 May 2015 02:17:22 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: mm: memory-hotplug: enable memory hotplug to handle hugepage
Date: Tue, 12 May 2015 09:16:40 +0000
Message-ID: <20150512091640.GE3068@hori1.linux.bs1.fc.nec.co.jp>
References: <20150511111748.GA20660@mwanda>
 <20150511235443.GA8513@hori1.linux.bs1.fc.nec.co.jp>
 <20150512084339.GN16501@mwanda>
 <20150512090454.GD3068@hori1.linux.bs1.fc.nec.co.jp>
 <20150512091349.GO16501@mwanda>
In-Reply-To: <20150512091349.GO16501@mwanda>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <45D026327805704DB7F48242F06E9852@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On Tue, May 12, 2015 at 12:13:49PM +0300, Dan Carpenter wrote:
> On Tue, May 12, 2015 at 02:04:55AM -0700, Naoya Horiguchi wrote:
> > On Tue, May 12, 2015 at 11:43:39AM +0300, Dan Carpenter wrote:
> > > On Mon, May 11, 2015 at 11:54:44PM +0000, Naoya Horiguchi wrote:
> > > > @@ -1086,7 +1086,8 @@ static void dissolve_free_huge_page(struct pa=
ge *page)
> > > >   */
> > > >  void dissolve_free_huge_pages(unsigned long start_pfn, unsigned lo=
ng end_pfn)
> > > >  {
> > > > -	unsigned int order =3D 8 * sizeof(void *);
> > > > +	/* Initialized to "high enough" value which is capped later */
> > > > +	unsigned int order =3D 8 * sizeof(void *) - 1;
> > >=20
> > > Why not use UINT_MAX?  It's more clear that it's not valid that way.
> >=20
> > It's OK if code checker doesn't show "too much right shift" warning.
>=20
> It's a comlicated question to answer but with the new VM_BUG_ON() then
> it won't warn.

Good, so I'll repost the patch soon later with revised description.

Thanks,
Naoya=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
