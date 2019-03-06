Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5EBDBC43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 10:56:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0551420684
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 10:56:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="YStbOKY2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0551420684
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 887048E0003; Wed,  6 Mar 2019 05:56:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 810178E0002; Wed,  6 Mar 2019 05:56:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6D92C8E0003; Wed,  6 Mar 2019 05:56:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 14B068E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 05:56:56 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id v8so2415462wmj.1
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 02:56:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:mime-version:subject
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=gFMy4yKGmwRBdn1oGAfnbpGsUUHokTp7MYJG67jJIv8=;
        b=i40VgL/IWhOF04IB6jlkvfWARwqMOq2Ei8Zy1t7BnSzF7iNbyHI9W8J02KpGoVKhJd
         YnkVUSF6SZQORj5V+LmU8XkpZVHqEwL+MwdmtuudDJKOd1YVHonGPsSFhfn1DD+tY/ni
         MGTLzxRZFyPq1faknF3jMSXW79cdd+x4BjFRKh6T6fXXCPs8ZDF76RXLYB+7H3OdkAv4
         io+UatqXSJhT355uboN0Bq17OWKsLxjSOAAt4B0JenGnqsblQi2YPQ3Iw61ysOwkdv/H
         Rzk9R3quDNDkWoMc4U6DHNZfv6EXjsCBeczTVaF6rLzsIg23xoA5BEEzlI6JhIzcFFa9
         GLvg==
X-Gm-Message-State: APjAAAX8G/fxOqM0r73RFEydtwAzY7ABa9QKA3G/AXwtcOqRrSWXvc6s
	sQz8U8DNE7kyhilklimQ6pjEpGidqh/PC/JkhZ5OtEmL00RZjLkKSLe4JPFyYOPCNUODXEii1sc
	zUEOqfWTwsvOdqzXHZpoZhiCgrlYEdKm9LpuIMiYVerbgQuzW+gbhhSAMmmx2OohfH5EkXil/xE
	+ORVlXzo2mDOB9PabXLRgtxWo7HcFG6MoGl1XdAPYes9IX+jQyBtHg3bcNYltzkM+XTdjVla90n
	xGb33DZlyFPiaPmtfsTnA5xAvNG3cJscWu6KtK7fVwSctcfYttAujuNMX/6MKNU2CJbOjyjt6rv
	qNRarFReXURG8+Euut6bq2M6x9i+3na/JZ7Iks7TWutV4LA9xmpQDUxhTjij5y8/xNQ+hcd9Q+8
	4
X-Received: by 2002:adf:fc87:: with SMTP id g7mr2454268wrr.136.1551869815593;
        Wed, 06 Mar 2019 02:56:55 -0800 (PST)
X-Received: by 2002:adf:fc87:: with SMTP id g7mr2454221wrr.136.1551869814720;
        Wed, 06 Mar 2019 02:56:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551869814; cv=none;
        d=google.com; s=arc-20160816;
        b=hmyhyzklt6K2xAn6wWnlpBIawWIzgO8LIC7+lPfyTbPx4wYq6vObfSAOL285MQskAh
         8YqGYMTxv+XMWHklj7yoeZP+h0v3ji3eBWoeDio9yq+VqsqFgZt2Ph1oI7dU0iJWt0Hw
         eZ3FhmGhtxoUGjR/ozPBoLAUlJ9MtLNFDqclw8996tNKxrzhkD9TbzMGrjjXc2lOhGR2
         UdB9h58rBF5lNnJYKJ+7zNna71eezNAnWYOHvlfcTQU0x6z6jUeLgm50kkBdpUa2mbyi
         2FVgloW3gu0vyM6LO8QHPbXzixjwy2V2sNSwmVI6x4J5tSybti2r3s5IrxM8SFEgi4WM
         ZTKQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:subject:mime-version:from:dkim-signature;
        bh=gFMy4yKGmwRBdn1oGAfnbpGsUUHokTp7MYJG67jJIv8=;
        b=Dlg82sS1Kq9HuW42HqjsWqUg4gIlxMG0iGyqmoTsUlWGe/JnVp9Kw+12q1fV2Mcp5k
         OVWV3qiLv6DU7KTjFIR2gsdAig3P72bq9W0wJFpZTtk4qML1MeRmQgWV60z/FJLSxyxN
         WmjgmWrg63XFEUS5OmQaUwhMciUomtUE1/dVcMn30vbJh5zsCaDSuHY3w3PBNJNu+WWS
         KQZBxLywJDdFPEl7QLMaxFWg1wIL5AiFZh9se61dnDO+qmlGc6spMJb658cd2fFz/dJH
         xq0oLLwfzh4q2DhMGDOD2rzGyXxxFgZzt9qrAY2fId3nu/cw/k5tSGynZAjn+u5Jz+3O
         5RFg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=YStbOKY2;
       spf=pass (google.com: domain of christophe.de.dinechin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=christophe.de.dinechin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j6sor1004361wme.6.2019.03.06.02.56.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Mar 2019 02:56:54 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.de.dinechin@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=YStbOKY2;
       spf=pass (google.com: domain of christophe.de.dinechin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=christophe.de.dinechin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:mime-version:subject:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=gFMy4yKGmwRBdn1oGAfnbpGsUUHokTp7MYJG67jJIv8=;
        b=YStbOKY2rA1qaeoZNioqvQlDymdnkW28AEDFz4M6byT4SIPNasLc3L+LA11thqnyE9
         sWOqbu7IOlk+aUjpYRnE3fAJG/nJ4TeDQ1SUd8/nIPiDKN+MdPjYiHv4+vIh+vfjA07s
         uKK91oy7ZS6HswFlct2O339LoJdkCuzlGrBtLH6lnX4afhvieD0dFvLxgwZ3tIf9K3fG
         AHE4Ny9ve8ALXF9VJXGLyrn/e/SYsDd2u10UKHlSW9eBDZER5iMzFAVYQSN3up+kFFIC
         7MLbZNaxUoGTfGjLWSONKJo5ptmLdFXqKid89g/69kvMp0Mgkr8fu/yIwR4tHxsowiOp
         0pSg==
X-Google-Smtp-Source: APXvYqxew9xO+g2MmJASOG7KsbOm4KUtyLBdg2SjHTlceW73LGPVilfYbBxMcZE3ULKxRQTcA7MNfw==
X-Received: by 2002:a1c:cf41:: with SMTP id f62mr2084998wmg.1.1551869814219;
        Wed, 06 Mar 2019 02:56:54 -0800 (PST)
Received: from [192.168.77.22] (val06-1-88-182-161-34.fbx.proxad.net. [88.182.161.34])
        by smtp.gmail.com with ESMTPSA id t202sm5032798wmt.0.2019.03.06.02.56.50
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Mar 2019 02:56:53 -0800 (PST)
From: Christophe de Dinechin <christophe.de.dinechin@gmail.com>
X-Google-Original-From: Christophe de Dinechin <christophe@dinechin.org>
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [RFC PATCH V2 4/5] vhost: introduce helpers to get the size of
 metadata area
In-Reply-To: <1551856692-3384-5-git-send-email-jasowang@redhat.com>
Date: Wed, 6 Mar 2019 11:56:48 +0100
Cc: mst@redhat.com,
 kvm@vger.kernel.org,
 virtualization@lists.linux-foundation.org,
 netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org,
 peterx@redhat.com,
 linux-mm@kvack.org,
 aarcange@redhat.com
Content-Transfer-Encoding: quoted-printable
Message-Id: <608E47C2-5130-41DE-9D52-02807EBCDD43@dinechin.org>
References: <1551856692-3384-1-git-send-email-jasowang@redhat.com>
 <1551856692-3384-5-git-send-email-jasowang@redhat.com>
To: Jason Wang <jasowang@redhat.com>
X-Mailer: Apple Mail (2.3445.9.1)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On 6 Mar 2019, at 08:18, Jason Wang <jasowang@redhat.com> wrote:
>=20
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
> drivers/vhost/vhost.c | 46 =
++++++++++++++++++++++++++++------------------
> 1 file changed, 28 insertions(+), 18 deletions(-)
>=20
> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> index 2025543..1015464 100644
> --- a/drivers/vhost/vhost.c
> +++ b/drivers/vhost/vhost.c
> @@ -413,6 +413,27 @@ static void vhost_dev_free_iovecs(struct =
vhost_dev *dev)
> 		vhost_vq_free_iovecs(dev->vqs[i]);
> }
>=20
> +static size_t vhost_get_avail_size(struct vhost_virtqueue *vq, int =
num)

Nit: Any reason not to make `num` unsigned or size_t?

> +{
> +	size_t event =3D vhost_has_feature(vq, VIRTIO_RING_F_EVENT_IDX) =
? 2 : 0;
> +
> +	return sizeof(*vq->avail) +
> +	       sizeof(*vq->avail->ring) * num + event;
> +}
> +
> +static size_t vhost_get_used_size(struct vhost_virtqueue *vq, int =
num)
> +{
> +	size_t event =3D vhost_has_feature(vq, VIRTIO_RING_F_EVENT_IDX) =
? 2 : 0;
> +
> +	return sizeof(*vq->used) +
> +	       sizeof(*vq->used->ring) * num + event;
> +}
> +
> +static size_t vhost_get_desc_size(struct vhost_virtqueue *vq, int =
num)
> +{
> +	return sizeof(*vq->desc) * num;
> +}
> +
> void vhost_dev_init(struct vhost_dev *dev,
> 		    struct vhost_virtqueue **vqs, int nvqs, int =
iov_limit)
> {
> @@ -1253,13 +1274,9 @@ static bool vq_access_ok(struct vhost_virtqueue =
*vq, unsigned int num,
> 			 struct vring_used __user *used)
>=20
> {
> -	size_t s =3D vhost_has_feature(vq, VIRTIO_RING_F_EVENT_IDX) ? 2 =
: 0;
> -
> -	return access_ok(desc, num * sizeof *desc) &&
> -	       access_ok(avail,
> -			 sizeof *avail + num * sizeof *avail->ring + s) =
&&
> -	       access_ok(used,
> -			sizeof *used + num * sizeof *used->ring + s);
> +	return access_ok(desc, vhost_get_desc_size(vq, num)) &&
> +	       access_ok(avail, vhost_get_avail_size(vq, num)) &&
> +	       access_ok(used, vhost_get_used_size(vq, num));
> }
>=20
> static void vhost_vq_meta_update(struct vhost_virtqueue *vq,
> @@ -1311,22 +1328,18 @@ static bool iotlb_access_ok(struct =
vhost_virtqueue *vq,
>=20
> int vq_meta_prefetch(struct vhost_virtqueue *vq)
> {
> -	size_t s =3D vhost_has_feature(vq, VIRTIO_RING_F_EVENT_IDX) ? 2 =
: 0;
> 	unsigned int num =3D vq->num;
>=20
> 	if (!vq->iotlb)
> 		return 1;
>=20
> 	return iotlb_access_ok(vq, VHOST_ACCESS_RO, =
(u64)(uintptr_t)vq->desc,
> -			       num * sizeof(*vq->desc), VHOST_ADDR_DESC) =
&&
> +			       vhost_get_desc_size(vq, num), =
VHOST_ADDR_DESC) &&
> 	       iotlb_access_ok(vq, VHOST_ACCESS_RO, =
(u64)(uintptr_t)vq->avail,
> -			       sizeof *vq->avail +
> -			       num * sizeof(*vq->avail->ring) + s,
> +			       vhost_get_avail_size(vq, num),
> 			       VHOST_ADDR_AVAIL) &&
> 	       iotlb_access_ok(vq, VHOST_ACCESS_WO, =
(u64)(uintptr_t)vq->used,
> -			       sizeof *vq->used +
> -			       num * sizeof(*vq->used->ring) + s,
> -			       VHOST_ADDR_USED);
> +			       vhost_get_used_size(vq, num), =
VHOST_ADDR_USED);
> }
> EXPORT_SYMBOL_GPL(vq_meta_prefetch);
>=20
> @@ -1343,13 +1356,10 @@ bool vhost_log_access_ok(struct vhost_dev =
*dev)
> static bool vq_log_access_ok(struct vhost_virtqueue *vq,
> 			     void __user *log_base)
> {
> -	size_t s =3D vhost_has_feature(vq, VIRTIO_RING_F_EVENT_IDX) ? 2 =
: 0;
> -
> 	return vq_memory_access_ok(log_base, vq->umem,
> 				   vhost_has_feature(vq, =
VHOST_F_LOG_ALL)) &&
> 		(!vq->log_used || log_access_ok(log_base, vq->log_addr,
> -					sizeof *vq->used +
> -					vq->num * sizeof *vq->used->ring =
+ s));
> +				  vhost_get_used_size(vq, vq->num)));
> }
>=20
> /* Can we start vq? */
> --=20
> 1.8.3.1
>=20

