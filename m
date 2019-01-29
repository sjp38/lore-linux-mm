Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4B27C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 19:33:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9410820856
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 19:33:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="vdnfDQ9J"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9410820856
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 364238E0002; Tue, 29 Jan 2019 14:33:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3129A8E0001; Tue, 29 Jan 2019 14:33:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1DC058E0002; Tue, 29 Jan 2019 14:33:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id BA2EC8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 14:33:00 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id f31so8259766edf.17
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 11:33:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=RCeCvFq5XVhGTYbx17dUhLsiytz0NldGx3wjwa/aDuA=;
        b=mDcnmeXzkA1IBNPJwbYo5fmxej+0XPv3OxvEZQwyNmIYP1c4xKyh3RpZ+XkI354qqE
         7WG6YdkDIvSpBrKOZpUhpYA+9VzT8sDLuGH1yd0a4jFVeW3INHjl6cJU3dEkM0uc9Fdb
         N4dd5l0eNJrHDem8h1hHonlg+2xrGxaFVLM7xClaoJlENYdWLQIWhwoiNL6bK1SnICWD
         FOByHP5+m/5I1zAnSeNIeAOl/8w8RflZFWMoOlhu2Duo8MRswR1hLCZEAgsfdpXnohGr
         OlN1RvhH+hHQSBVG653R7t9akVM1q/LHUE3rNyCjmHqziRj2jhZ/hwpJdR00qJ1eyNIm
         EnYQ==
X-Gm-Message-State: AJcUukdTBYRLuHF8wvLC0CJ0UTBK2Gu9GXndoSJPINW8/IBDRSA4pEyg
	Ht4+m1AY6NZHJarrginFMiuVg7kubNclVxKazGLVYb1gi8cnxf7Cqs2ARNSElkA9b4eBD+f8WK5
	3j8HyUsLBpAxJ6P+c8ZnJSCjuvXYl4JV+znMTPA+a5dfIal7M049PjrR82sdjGG5DnA==
X-Received: by 2002:a17:906:3e49:: with SMTP id t9mr9244938eji.245.1548790380175;
        Tue, 29 Jan 2019 11:33:00 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6lqYUYj5NKbEJj+elZ3zPQx/JQ84e8I9yD3bMBCjnIzSQYmjN4C2a2RUSs/xlngKx8ek9s
X-Received: by 2002:a17:906:3e49:: with SMTP id t9mr9244887eji.245.1548790379246;
        Tue, 29 Jan 2019 11:32:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548790379; cv=none;
        d=google.com; s=arc-20160816;
        b=Y5wLZnFtPOc2FCBSOVQ8hPAqkIuvT+Ku7Xum/TGnHgX9gP+LF49a8iCFHDmsyoeJDS
         keCcioLuYD/4IV4oJ/c3H3yYAL5evVsHT7wbfAZS7IrJdT4Tgt50qu0ynm+JQ3up7zgf
         AQXuW7F1bAPkvBz0JwMXU1GsBt9ViXPbxlNjwPJtSHfomxmbRAwGytmiJ8sIGyg2Dxz9
         hlAwzRaoXdofZTRdJBL5p2DovpopZtaLu+GQc8Vp5d12YyeYa6kBvxFxCE3smcxMHFbk
         +HsdIvWN9du2qKq4DsTiiewG9/fgGXP1JZVHIXn/7LccLALRUQ+poj9Gj2iW1K5BSHmg
         ReLQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=RCeCvFq5XVhGTYbx17dUhLsiytz0NldGx3wjwa/aDuA=;
        b=W9XtqfM0O24Vuid16WOAQ9tsu71Qjzr2Hv1qzAFyfr7wmHaF1EsRK8gtjXQzZE3Am6
         3gu3A/mbvX00p7V321+XTlpUkzaDR9sFUn7J/aGWGAgACPOL4Am/clbbv8LenYtkBbM4
         rrDcr6dYpU1UKsuflHToDHd6zv37Gwn0Nzr7OfhMjbB9E24nxQhgtYvpI4t+2p5M5eVM
         1Qq/Z69x13HLJtOvj9Z+VJ2JfV/bbo8arT4mNgyy/ERhmIsMax5noqODC6afnd/M1Yyt
         kX3Wy61CMzekddnOjSCRBoEMzueh2BhwMq+LcAsL0z/LMZZwKW5+Cf9g6M4XMr61u2Bz
         pbjw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector1 header.b=vdnfDQ9J;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.14.73 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-eopbgr140073.outbound.protection.outlook.com. [40.107.14.73])
        by mx.google.com with ESMTPS id 15-v6si4108503ejw.36.2019.01.29.11.32.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 11:32:59 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.14.73 as permitted sender) client-ip=40.107.14.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector1 header.b=vdnfDQ9J;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.14.73 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=RCeCvFq5XVhGTYbx17dUhLsiytz0NldGx3wjwa/aDuA=;
 b=vdnfDQ9JxvIFql16cWL6ZEdYnR4ZIhzj1LaY0F0UodLC3GqrNX8oEUHkKRtGjKqfvrubWcc6c0pwUK/ghh7lyn1hn+r1odKHUxU0AoB5h5aI9PgJOIXgYTAgRM/++TSOLA5MJFLZSR230aX0xP0XDF0Mn0yp94i5Q/kss3aln98=
Received: from DBBPR05MB6426.eurprd05.prod.outlook.com (20.179.42.80) by
 DBBPR05MB6521.eurprd05.prod.outlook.com (20.179.43.146) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1558.21; Tue, 29 Jan 2019 19:32:57 +0000
Received: from DBBPR05MB6426.eurprd05.prod.outlook.com
 ([fe80::24c2:321d:8b27:ae59]) by DBBPR05MB6426.eurprd05.prod.outlook.com
 ([fe80::24c2:321d:8b27:ae59%5]) with mapi id 15.20.1580.017; Tue, 29 Jan 2019
 19:32:57 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Jerome Glisse <jglisse@redhat.com>
CC: Logan Gunthorpe <logang@deltatee.com>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, Greg Kroah-Hartman
	<gregkh@linuxfoundation.org>, "Rafael J . Wysocki" <rafael@kernel.org>, Bjorn
 Helgaas <bhelgaas@google.com>, Christian Koenig <christian.koenig@amd.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>, "linux-pci@vger.kernel.org"
	<linux-pci@vger.kernel.org>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, Christoph Hellwig <hch@lst.de>, Marek
 Szyprowski <m.szyprowski@samsung.com>, Robin Murphy <robin.murphy@arm.com>,
	Joerg Roedel <jroedel@suse.de>, "iommu@lists.linux-foundation.org"
	<iommu@lists.linux-foundation.org>
Subject: Re: [RFC PATCH 3/5] mm/vma: add support for peer to peer to device
 vma
Thread-Topic: [RFC PATCH 3/5] mm/vma: add support for peer to peer to device
 vma
Thread-Index: AQHUt/rA/dLikqWEmEaIytHIBNLPlqXGkyOAgAAJwICAAAX+AA==
Date: Tue, 29 Jan 2019 19:32:57 +0000
Message-ID: <20190129193250.GK10108@mellanox.com>
References: <20190129174728.6430-1-jglisse@redhat.com>
 <20190129174728.6430-4-jglisse@redhat.com>
 <ae928aa5-a659-74d5-9734-15dfefafd3ea@deltatee.com>
 <20190129191120.GE3176@redhat.com>
In-Reply-To: <20190129191120.GE3176@redhat.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: MWHPR18CA0035.namprd18.prod.outlook.com
 (2603:10b6:320:31::21) To DBBPR05MB6426.eurprd05.prod.outlook.com
 (2603:10a6:10:c9::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [174.3.196.123]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics:
 1;DBBPR05MB6521;6:qIbxigtUfkce/aMkXuRgQE4oq5eXlBXrRd/jmJ5Qr/6ngJ/uwqYQOPpxbXYM04QRcyHkN82A/spgU4PUT3jz2YXpu4CA9ee9Pna2FeHYbN+GKOXxxCa3HyczKAqz5k1uU757rUZEex+bPnRFm+6byGQiWIln0D3yqtVLAfjSxrMdfM7+p0MqiFYW3hyQU3kg94AJjdn6XDSttgpi7BNkoUSli8yddtV+vehYJL9F1KevuVw1d692y8E73vDvYfEsGJ3xINPjixg+X9Z8xECxPAsXoxbcnMq8hHa0ODK7UB/rge7PJbOZy3STbizMDR3GFKa/bJSkWOTeRpbiYe52A1VXZ//1RX2pX+nQIOyTOvr7fmQGdfnm5b97BdwkmvCKXpsI6Km4a/OCNPK55A2vVO8Y1Y4zl2yIL1BVpeUsp52BSZ3ddTJFEH50OaLbdWshsyov2FNyGV4AZ5vBf6d8UA==;5:2GZ7euKQlvTfiqVwXrnJCz8M6EvBeyko7iuRIvF7731btWTkgO9KrxSN39D6ohvx182vA7dAvViUe37Zv4xJoykjz60+ycJykbZu536QyEV305fKwwVEPgXQe5pZIcVPY4Jy11z8lGOc4nI/IizIzlnhLb8pYJaACpHaWlJw7rxjW9k+tTnBvun2KrF5W30tGSf3Ic3EhzjwN/3A39ewgw==;7:x9MT+0b2q51C3b51zXY06WZ/TtiA0iPhzx7B0C9WudXXE13v8JoWPAxTyYOMoh+k/VGJaswtdeKFXUPe7G+h7nZhBqK3zx7Xu4CpsyXNy8qNI544EiPGCZguWlzdzkXpvGA0Qj/lg7AreAKNA2Uzew==
x-ms-office365-filtering-correlation-id: 7be37d8f-8eaa-4788-672c-08d68620923a
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605077)(4618075)(2017052603328)(7153060)(7193020);SRVR:DBBPR05MB6521;
x-ms-traffictypediagnostic: DBBPR05MB6521:
x-microsoft-antispam-prvs:
 <DBBPR05MB652119A47580243302A3E300CF970@DBBPR05MB6521.eurprd05.prod.outlook.com>
x-forefront-prvs: 093290AD39
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(136003)(346002)(39860400002)(396003)(366004)(376002)(189003)(199004)(6486002)(14454004)(6116002)(2906002)(6512007)(71190400001)(68736007)(6436002)(71200400001)(478600001)(229853002)(446003)(217873002)(53936002)(97736004)(6246003)(3846002)(486006)(476003)(11346002)(2616005)(105586002)(81166006)(93886005)(8676002)(81156014)(1076003)(6916009)(7736002)(305945005)(14444005)(316002)(76176011)(8936002)(4326008)(186003)(256004)(106356001)(386003)(26005)(99286004)(33656002)(36756003)(53546011)(52116002)(86362001)(25786009)(54906003)(7416002)(102836004)(6506007)(66066001);DIR:OUT;SFP:1101;SCL:1;SRVR:DBBPR05MB6521;H:DBBPR05MB6426.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 yVFGJimFHdkRHGZUQ1MMQGCuCVv2izL3ZjyZgutu5AfiQxWQQjrJC9OQuCPfiOfo3/Dpkdya/XtSnSmmGlY1uTlnbhDXIHWHSFUTM2BXO0kRBhfut8ej+bC/k+W0C6193Rz6nr4/aKX+hIjV2dwVE+BlM9OwgM7eGzA1LLD93crfqe4nU8QTsjXnLGAVIcj3lrPcw+h3yeyD2JFYK521/sbr1QmBDyQIk6bUjyQNr7nzwcqWl9YmdyphjR4q9c/k4fqYLrzpNVQXp7lAeY0PuHYV7LB/fNGuzVhtrdZxkCBktbUH+wRAwEAWcHsDlcHTfTYYFhlU25nsGfL4dFByjCOpb/ctAGEEmC4XN2cwJR6H7ZJH56Tnw+p5TyNrPQ2rS40JkAKGty3Dbl9LUlM8mhq/fOrC7Qv2JsX+5Rpq8x8=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <D743145BE1A96C40B172B73A6FC4A399@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 7be37d8f-8eaa-4788-672c-08d68620923a
X-MS-Exchange-CrossTenant-originalarrivaltime: 29 Jan 2019 19:32:56.9860
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DBBPR05MB6521
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 02:11:23PM -0500, Jerome Glisse wrote:
> On Tue, Jan 29, 2019 at 11:36:29AM -0700, Logan Gunthorpe wrote:
> >=20
> >=20
> > On 2019-01-29 10:47 a.m., jglisse@redhat.com wrote:
> >=20
> > > +	/*
> > > +	 * Optional for device driver that want to allow peer to peer (p2p)
> > > +	 * mapping of their vma (which can be back by some device memory) t=
o
> > > +	 * another device.
> > > +	 *
> > > +	 * Note that the exporting device driver might not have map anythin=
g
> > > +	 * inside the vma for the CPU but might still want to allow a peer
> > > +	 * device to access the range of memory corresponding to a range in
> > > +	 * that vma.
> > > +	 *
> > > +	 * FOR PREDICTABILITY IF DRIVER SUCCESSFULY MAP A RANGE ONCE FOR A
> > > +	 * DEVICE THEN FURTHER MAPPING OF THE SAME IF THE VMA IS STILL VALI=
D
> > > +	 * SHOULD ALSO BE SUCCESSFUL. Following this rule allow the importi=
ng
> > > +	 * device to map once during setup and report any failure at that t=
ime
> > > +	 * to the userspace. Further mapping of the same range might happen
> > > +	 * after mmu notifier invalidation over the range. The exporting de=
vice
> > > +	 * can use this to move things around (defrag BAR space for instanc=
e)
> > > +	 * or do other similar task.
> > > +	 *
> > > +	 * IMPORTER MUST OBEY mmu_notifier NOTIFICATION AND CALL p2p_unmap(=
)
> > > +	 * WHEN A NOTIFIER IS CALL FOR THE RANGE ! THIS CAN HAPPEN AT ANY
> > > +	 * POINT IN TIME WITH NO LOCK HELD.
> > > +	 *
> > > +	 * In below function, the device argument is the importing device,
> > > +	 * the exporting device is the device to which the vma belongs.
> > > +	 */
> > > +	long (*p2p_map)(struct vm_area_struct *vma,
> > > +			struct device *device,
> > > +			unsigned long start,
> > > +			unsigned long end,
> > > +			dma_addr_t *pa,
> > > +			bool write);
> > > +	long (*p2p_unmap)(struct vm_area_struct *vma,
> > > +			  struct device *device,
> > > +			  unsigned long start,
> > > +			  unsigned long end,
> > > +			  dma_addr_t *pa);
> >=20
> > I don't understand why we need new p2p_[un]map function pointers for
> > this. In subsequent patches, they never appear to be set anywhere and
> > are only called by the HMM code. I'd have expected it to be called by
> > some core VMA code and set by HMM as that's what vm_operations_struct i=
s
> > for.
> >=20
> > But the code as all very confusing, hard to follow and seems to be
> > missing significant chunks. So I'm not really sure what is going on.
>=20
> It is set by device driver when userspace do mmap(fd) where fd comes
> from open("/dev/somedevicefile"). So it is set by device driver. HMM
> has nothing to do with this. It must be set by device driver mmap
> call back (mmap callback of struct file_operations). For this patch
> you can completely ignore all the HMM patches. Maybe posting this as
> 2 separate patchset would make it clearer.
>=20
> For instance see [1] for how a non HMM driver can export its memory
> by just setting those callback. Note that a proper implementation of
> this should also include some kind of driver policy on what to allow
> to map and what to not allow ... All this is driver specific in any
> way.

I'm imagining that the RDMA drivers would use this interface on their
per-process 'doorbell' BAR pages - we also wish to have P2P DMA to
this memory. Also the entire VFIO PCI BAR mmap would be good to cover
with this too.

Jerome, I think it would be nice to have a helper scheme - I think the
simple case would be simple remapping of PCI BAR memory, so if we
could have, say something like:

static const struct vm_operations_struct my_ops {
  .p2p_map =3D p2p_ioremap_map_op,
  .p2p_unmap =3D p2p_ioremap_unmap_op,
}

struct ioremap_data {
  [..]
}

fops_mmap() {
   vma->private_data =3D &driver_priv->ioremap_data;
   return p2p_ioremap_device_memory(vma, exporting_device, [..]);
}

Which closely matches at least what the RDMA drivers do. Where
p2p_ioremap_device_memory populates p2p_map and p2p_unmap pointers
with sensible functions, etc.

It looks like vfio would be able to use this as well (though I am
unsure why vfio uses remap_pfn_range instead of io_remap_pfn range for
BAR memory..)

Do any drivers need more control than this?

Jason

