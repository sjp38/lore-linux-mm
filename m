Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94D88C433FF
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 07:14:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 571732086C
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 07:14:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=ffwll.ch header.i=@ffwll.ch header.b="VhXMIl/e"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 571732086C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ffwll.ch
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E2F3C6B0003; Thu, 15 Aug 2019 03:14:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DB9A06B0005; Thu, 15 Aug 2019 03:14:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CA6E86B0007; Thu, 15 Aug 2019 03:14:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0004.hostedemail.com [216.40.44.4])
	by kanga.kvack.org (Postfix) with ESMTP id A3FE56B0003
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 03:14:20 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 424152DFB
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 07:14:20 +0000 (UTC)
X-FDA: 75823798680.18.feast07_25c66c73f0433
X-HE-Tag: feast07_25c66c73f0433
X-Filterd-Recvd-Size: 6562
Received: from mail-ed1-f65.google.com (mail-ed1-f65.google.com [209.85.208.65])
	by imf34.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 07:14:19 +0000 (UTC)
Received: by mail-ed1-f65.google.com with SMTP id g8so1344217edm.6
        for <linux-mm@kvack.org>; Thu, 15 Aug 2019 00:14:19 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ffwll.ch; s=google;
        h=sender:date:from:to:cc:subject:message-id:mail-followup-to
         :references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=rjonirMyNKFLmr6pNWt9/0hY9meFYjEaFyv9/3cyMYc=;
        b=VhXMIl/eHGwrgkMfakF/qwMwhZWtWXKUF49966PDQfDBaReTfTCf/9nggMPlMNxWd0
         5XGY5nleuGWkyUPLKbEn0i0w72q4fQknknNeCXEqoKNJzPn1PhygwPcQnXfTc4lcwPVZ
         nORHA6FNAFB2JO91ROMe5aGnJiwmdIbl2oD7w=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:date:from:to:cc:subject:message-id
         :mail-followup-to:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=rjonirMyNKFLmr6pNWt9/0hY9meFYjEaFyv9/3cyMYc=;
        b=BlB8xtmrqgaGafnBxi3bv7UY4H0RGuylf1Gg5ZJWW0z8FfZIXdO5HPAE1WNWTc0XsU
         W5iDUNnC6JP6SI7d7TpziYPs9xQqX/kNE5XjNKe0GX/ER9SVEmsxztVjkbt7uy4vwWyy
         3YgPb5wrEGgzNNoR0FFEVUjs9NtFtBI8cYANbHccv8915Kq+7faLpYHFB0jXDQ8Iyu48
         yKLM446J2AllyiYj0NRJ8xoH9lQTJvfFOU1l7Tsv+oak7zVnqzTX+jdtLgOymYBBfB5f
         AS1DYDcYxh9XSay6UsZby2E3/Hcw28HdSbxjgShCWVm9LVy3SPmENF74vQm1heq+UyPt
         4CJg==
X-Gm-Message-State: APjAAAWZDz48b+eQQiy2N6KZnVXtaZTGnrhV1X4w+NDypBF0R3kHDduV
	yovP9vW4S0vwaho9+2ThPGp4ng==
X-Google-Smtp-Source: APXvYqxHFed471aqkz65evmjZ3bTGMMJcAWmhTm+eeuK6Ic5QidqvFlMXSewSwbHwYbGaD4JTt8JMw==
X-Received: by 2002:a17:906:504e:: with SMTP id e14mr178194ejk.204.1565853258482;
        Thu, 15 Aug 2019 00:14:18 -0700 (PDT)
Received: from phenom.ffwll.local ([2a02:168:569e:0:3106:d637:d723:e855])
        by smtp.gmail.com with ESMTPSA id br8sm265471ejb.92.2019.08.15.00.14.16
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 15 Aug 2019 00:14:17 -0700 (PDT)
Date: Thu, 15 Aug 2019 09:14:15 +0200
From: Daniel Vetter <daniel@ffwll.ch>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Daniel Vetter <daniel.vetter@ffwll.ch>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Matthew Wilcox <willy@infradead.org>, Arnd Bergmann <arnd@arndb.de>,
	Balbir Singh <bsingharora@gmail.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Daniel Vetter <daniel.vetter@intel.com>
Subject: Re: [PATCH 5/5] mm/hmm: WARN on illegal ->sync_cpu_device_pagetables
 errors
Message-ID: <20190815071415.GD7444@phenom.ffwll.local>
Mail-Followup-To: Jason Gunthorpe <jgg@ziepe.ca>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Matthew Wilcox <willy@infradead.org>, Arnd Bergmann <arnd@arndb.de>,
	Balbir Singh <bsingharora@gmail.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Daniel Vetter <daniel.vetter@intel.com>
References: <20190814202027.18735-1-daniel.vetter@ffwll.ch>
 <20190814202027.18735-6-daniel.vetter@ffwll.ch>
 <20190815001137.GE11200@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20190815001137.GE11200@ziepe.ca>
X-Operating-System: Linux phenom 4.19.0-5-amd64 
User-Agent: Mutt/1.10.1 (2018-07-13)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 14, 2019 at 09:11:37PM -0300, Jason Gunthorpe wrote:
> On Wed, Aug 14, 2019 at 10:20:27PM +0200, Daniel Vetter wrote:
> > Similar to the warning in the mmu notifer, warning if an hmm mirror
> > callback gets it's blocking vs. nonblocking handling wrong, or if it
> > fails with anything else than -EAGAIN.
> >=20
> > Cc: Jason Gunthorpe <jgg@ziepe.ca>
> > Cc: Ralph Campbell <rcampbell@nvidia.com>
> > Cc: John Hubbard <jhubbard@nvidia.com>
> > Cc: Dan Williams <dan.j.williams@intel.com>
> > Cc: Dan Carpenter <dan.carpenter@oracle.com>
> > Cc: Matthew Wilcox <willy@infradead.org>
> > Cc: Arnd Bergmann <arnd@arndb.de>
> > Cc: Balbir Singh <bsingharora@gmail.com>
> > Cc: Ira Weiny <ira.weiny@intel.com>
> > Cc: Souptick Joarder <jrdr.linux@gmail.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: "J=E9r=F4me Glisse" <jglisse@redhat.com>
> > Cc: linux-mm@kvack.org
> > Signed-off-by: Daniel Vetter <daniel.vetter@intel.com>
> >  mm/hmm.c | 3 +++
> >  1 file changed, 3 insertions(+)
> >=20
> > diff --git a/mm/hmm.c b/mm/hmm.c
> > index 16b6731a34db..52ac59384268 100644
> > +++ b/mm/hmm.c
> > @@ -205,6 +205,9 @@ static int hmm_invalidate_range_start(struct mmu_=
notifier *mn,
> >  			ret =3D -EAGAIN;
> >  			break;
> >  		}
> > +		WARN(ret, "%pS callback failed with %d in %sblockable context\n",
> > +		     mirror->ops->sync_cpu_device_pagetables, ret,
> > +		     update.blockable ? "" : "non-");
> >  	}
> >  	up_read(&hmm->mirrors_sem);
>=20
> Didn't I beat you to this?

Very much possible, I think I didn't rebase this to linux-next before
resending ... have an

Reviewed-by: Daniel Vetter <daniel.vetter@ffwll.ch>

in case you need.

Cheers, Daniel

>=20
> 	list_for_each_entry(mirror, &hmm->mirrors, list) {
> 		int rc;
>=20
> 		rc =3D mirror->ops->sync_cpu_device_pagetables(mirror, &update);
> 		if (rc) {
> 			if (WARN_ON(update.blockable || rc !=3D -EAGAIN))
> 				continue;
> 			ret =3D -EAGAIN;
> 			break;
> 		}
> 	}
>=20
> Thanks,
> Jason

--=20
Daniel Vetter
Software Engineer, Intel Corporation
http://blog.ffwll.ch

