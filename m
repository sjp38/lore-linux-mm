Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F2D5C282D8
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 18:14:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E532121473
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 18:14:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="rli5gtMI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E532121473
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8B9808E0004; Wed, 30 Jan 2019 13:14:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 867778E0001; Wed, 30 Jan 2019 13:14:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 72F218E0004; Wed, 30 Jan 2019 13:14:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3EA088E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 13:14:34 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id u126so256002ywb.0
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 10:14:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=vRFnZGny9hUnD9eny/611Mn7d12FxGlSSC/uexCXw2o=;
        b=WC7p/GUbiSTTtl7dmeLRLs8APfKgBrwW0sn2Nv1g8kUmmo/pGdzLIcwzBXrtQbmsTY
         D/NIBYvC+s+gAo7YYqHHLzwWaV5oVuLMzsoZINaMwJB+wMDKTXtIa4xGW45p8CBNAE/b
         3zbQGcOo6pEUprWYa0ykTDemD9j7Mofdvv42TszVOGclKsGhKPDTYFZiZPQ8A3RUNSB2
         +trmoN8cvYKPSRHlI3fwVnL08UwJQMgKyoToDKnXw+3eABcYT9AU0aa2e0b9g5kZWe7b
         uHu26oXm2tmL1sIKZNgCPT5pKAwLW1qh4yPidd5OxaQRu/wn3ekJmjoNEOeraEQbCykS
         OkIA==
X-Gm-Message-State: AJcUukcDhiWuUGHvnG5Gn8z8pmfO1xPaBsGzh8RDR089gqXOntjx4szH
	XkJPTUzUAGn6yLCRd7H28r2UEZjyBv83j4daCKkjy7ihlhIXGkNbOddkosY9OLxj/Btgdl9wzAP
	6IxGxt05EJfm3UEWj/tULfvQVWdB0dKZGBfcBjLMMNQHgWAVa2KuHsFKOLE/Xwqob0g==
X-Received: by 2002:a0d:d454:: with SMTP id w81mr30820479ywd.110.1548872072415;
        Wed, 30 Jan 2019 10:14:32 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6lYvFBwBn3s5nIh4pV9hnAWZxCNt2sS+2/y+ZZ26CDrUh2883xbweCmYPNLhM72g7WGqmX
X-Received: by 2002:a0d:d454:: with SMTP id w81mr30820330ywd.110.1548872070197;
        Wed, 30 Jan 2019 10:14:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548872070; cv=none;
        d=google.com; s=arc-20160816;
        b=mcDQWmAEltLecNIL6QDM2PcUWUCRB3WO3uuHygPv5mpPNhwbxUF7A89F5jfmqwrga1
         tteN6Yo1W172PKKEOaA4zwKa/MpVPRZtcO9afbg7EQ3KUa5i20vUHMwg1LWjmn/eabnN
         VtUSEk0ezGBg14il6rSKCx2oMwZTkImGx2M/EkREghIzHucTGg8a6WFkFZIWAtcmGqyN
         KMbINC3hT3vY6V3h9MUppWPWEd8edR8lVjzQewUf7hWiWRWLphiPfWA3DulzNRj00/df
         eabCJcJfWmkb8flFG+MXUHjW6PgrRolxapfHQ8i+BuJu9Euhb/i6eNSDiPVi6ejGxd8M
         3/fw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=vRFnZGny9hUnD9eny/611Mn7d12FxGlSSC/uexCXw2o=;
        b=fGkX5nac5L9Vnf1T72L0Vyh/Z2x+qbYy7PkYTMc1m0v+sPpV6XUUPHsyNHpONtivQa
         Oud2IZf3vKBqH/w78x54G1gQAQEeGUMuMhV5Jg04xsBSj68UFg41HiTw2aG8uJSZwZJz
         +Nf/ww5MjncqrQoIM385yhDx/bQN3cd4PhY69DH9t6WS5iyUIXBlWeHqEv9Qz388iZtx
         IX9p7JfaHI5wdlIajOgrqmrNhx+TpbV5DbLYGJs5PxmlmbDi8qFYw2ADtEDxqd5WGdmk
         LPTgJMsYdpFjGFLhvMfmXCM9LVNfxUdZPaBCfMHT6Wfkz61MB3kzYVq3CxxCobHL/YjX
         zFnQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=rli5gtMI;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id 23si1217534ywf.445.2019.01.30.10.14.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 10:14:30 -0800 (PST)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=rli5gtMI;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c51e9690000>; Wed, 30 Jan 2019 10:14:01 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Wed, 30 Jan 2019 10:14:29 -0800
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Wed, 30 Jan 2019 10:14:29 -0800
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Wed, 30 Jan
 2019 18:14:28 +0000
Subject: Re: [v3 PATCH] mm: ksm: do not block on page lock when searching
 stable tree
To: Yang Shi <yang.shi@linux.alibaba.com>, <ktkhai@virtuozzo.com>,
	<hughd@google.com>, <aarcange@redhat.com>, <akpm@linux-foundation.org>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>
References: <1548793753-62377-1-git-send-email-yang.shi@linux.alibaba.com>
 <82ba1395-baab-3b95-a3f7-47e219551881@nvidia.com>
 <7cf16cfb-3190-dfbd-ce72-92a94d9277f5@linux.alibaba.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <9bf60825-286f-d46c-b6d5-ee8bfffaaa48@nvidia.com>
Date: Wed, 30 Jan 2019 10:14:28 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <7cf16cfb-3190-dfbd-ce72-92a94d9277f5@linux.alibaba.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL103.nvidia.com (172.20.187.11) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1548872041; bh=vRFnZGny9hUnD9eny/611Mn7d12FxGlSSC/uexCXw2o=;
	h=X-PGP-Universal:Subject:To:CC:References:From:Message-ID:Date:
	 User-Agent:MIME-Version:In-Reply-To:X-Originating-IP:
	 X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=rli5gtMIAFpKXWV/KbzHzT5AIrb3FbVc7sMVRw+V8zZHiJE4y6MvNz1NiK9Hnx7Sl
	 Zplal1p/QflKbl/jb6FEsKs0W2mVCTgC5XOWGn1cyT8phMAQHCe1ayZzol5rieXEzE
	 ZKkGLyBNdeIccVbLZuT9iWpZKbJ0sLCH7SctfnEOil4gGOd6l1oJnEHiuel2EkjHlT
	 eVlthmdkOgV2SM7Ho/uuOKn7iTbZnrOxTZphLT5lFm/CXapXf9RORKmH0ci3oHZAfY
	 QXv/a+8oXTi255Avi9r7XdMI4bwhG3neFpS3GtoMes/ugRQUmYKQ9iCt+aCNA1vqxJ
	 l8cRsAGO8TXVg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 1/30/19 9:47 AM, Yang Shi wrote:
[...]
>>> @@ -1673,7 +1688,12 @@ static struct page *stable_tree_search(struct pa=
ge *page)
>>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0 * It would be more elegant to return stable_node
>>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0 * than kpage, but that involves more changes.
>>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0 */
>>> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 tre=
e_page =3D get_ksm_page(stable_node_dup, true);
>>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 tre=
e_page =3D get_ksm_page(stable_node_dup,
>>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
 GET_KSM_PAGE_TRYLOCK);
>>> +
>>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 if =
(PTR_ERR(tree_page) =3D=3D -EBUSY)
>>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0 return ERR_PTR(-EBUSY);
>>
>> or just:
>>
>> =C2=A0=C2=A0=C2=A0=C2=A0if (PTR_ERR(tree_page) =3D=3D -EBUSY)
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 return tree_page;
>>
>> right?
>=20
> Either looks fine to me. Returning errno may look more explicit? Anyway I=
 really don't have preference.

Yes, either one is fine. I like to see less code on the screen, all else be=
ing equal,
but it's an extremely minor point, and sometimes being explicit instead is =
better anyway.



thanks,
--=20
John Hubbard
NVIDIA

