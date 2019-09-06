Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 29545C43331
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 03:22:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 07999206A3
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 03:22:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 07999206A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sina.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 648D06B0003; Thu,  5 Sep 2019 23:22:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5D2126B0006; Thu,  5 Sep 2019 23:22:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4BFFA6B0007; Thu,  5 Sep 2019 23:22:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0163.hostedemail.com [216.40.44.163])
	by kanga.kvack.org (Postfix) with ESMTP id 213E26B0003
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 23:22:11 -0400 (EDT)
Received: from smtpin02.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id BB3D63D19
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 03:22:10 +0000 (UTC)
X-FDA: 75903047220.02.swim90_12dc1aebc5f17
X-HE-Tag: swim90_12dc1aebc5f17
X-Filterd-Recvd-Size: 1758
Received: from r3-18.sinamail.sina.com.cn (r3-18.sinamail.sina.com.cn [202.108.3.18])
	by imf29.hostedemail.com (Postfix) with SMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 03:22:09 +0000 (UTC)
Received: from unknown (HELO localhost.localdomain)([114.254.173.51])
	by sina.com with ESMTP
	id 5D71D0DB00003D7B; Fri, 6 Sep 2019 11:22:06 +0800 (CST)
X-Sender: hdanton@sina.com
X-Auth-ID: hdanton@sina.com
X-SMAIL-MID: 70821515074454
From: Hillf Danton <hdanton@sina.com>
To: Jason Wang <jasowang@redhat.com>
Cc: mst@redhat.com,
	kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	jgg@mellanox.com,
	aarcange@redhat.com,
	jglisse@redhat.com,
	linux-mm@kvack.org,
	James Bottomley <James.Bottomley@hansenpartnership.com>,
	Christoph Hellwig <hch@infradead.org>,
	David Miller <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org,
	linux-parisc@vger.kernel.org
Subject: Re: [PATCH 2/2] vhost: re-introducing metadata acceleration through kernel virtual address
Date: Fri,  6 Sep 2019 11:21:54 +0800
Message-Id: <20190906032154.9376-1-hdanton@sina.com>
In-Reply-To: <20190905122736.19768-1-jasowang@redhat.com>
References: <20190905122736.19768-1-jasowang@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On Thu,  5 Sep 2019 20:27:36 +0800 From:   Jason Wang <jasowang@redhat.co=
m>
>=20
> +static void vhost_set_map_dirty(struct vhost_virtqueue *vq,
> +				struct vhost_map *map, int index)
> +{
> +	struct vhost_uaddr *uaddr =3D &vq->uaddrs[index];
> +	int i;
> +
> +	if (uaddr->write) {
> +		for (i =3D 0; i < map->npages; i++)
> +			set_page_dirty(map->pages[i]);
> +	}

Not sure need to set page dirty under page lock.



