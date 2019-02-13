Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 796DEC4151A
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 07:32:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0A789222BE
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 07:32:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="Yj9LduyX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0A789222BE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=iki.fi
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6ECE38E0002; Wed, 13 Feb 2019 02:32:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 69CD08E0001; Wed, 13 Feb 2019 02:32:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 566068E0002; Wed, 13 Feb 2019 02:32:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 28C4A8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 02:32:42 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id q33so1347250qte.23
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 23:32:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=+/C6EaNfq8gXsgMCYQEEr71KXJaPBdUxGSd0IfnMFlg=;
        b=TLBAPoeGaC2Xs+I1k3aPrlneSkY1CB8sK/IR+3lZULYNW2nrt7hQFxqtu71ubO1G1v
         PHdMnpRNg5mDj9pJo9sxChAxY9WxjT4ha+MKj+yQSbkxBIlQXwpobT3bw9Vw4GNDPvGu
         QckSnqNTQbcnRHUV8vQ5HpLFJ2tuK1B8ULESQSLTnGgCmQS8820iiAfDuhGbXIY9BdLa
         oz6wC+jb2MpfyFnSHSpApYRsgjVjkWIzk6a5O5kSFr03kWPOG416PVm9/85VmrWtDW5G
         5PCW+Q7UyPxd+Du2fNDX75dReQplA6TzqpHQyUt/b3Y3QoB7qI7eVX+iSPvzSH6vstnJ
         O8jw==
X-Gm-Message-State: AHQUAuYT4HM6r2iVQETuL5c8UfVM0Lnk8dY6+Kx4XBG0X3QLpgYGQ1QD
	M2i0tTK2tss5e0Gjof9AaVf6kjXXhD2rcx0eWC8LWVciZp8tNZ2wJ4EUtQ+zgM1tV4N3krb1qVg
	P2GkCJJL9BFVe/mUHRTfgEnoxk8RqJbgeIhcK98yFF1/tybwlMO4ht9uBsPAcglc=
X-Received: by 2002:a37:d204:: with SMTP id f4mr5460142qkj.311.1550043161837;
        Tue, 12 Feb 2019 23:32:41 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaGmJc0kEe+DMHklbKiZPX6+0hd/nSO1jNAP6Lj+NeOt3fn/Qs1L8Qe3haFNM2oPbkRf/Kn
X-Received: by 2002:a37:d204:: with SMTP id f4mr5460122qkj.311.1550043161339;
        Tue, 12 Feb 2019 23:32:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550043161; cv=none;
        d=google.com; s=arc-20160816;
        b=NMGU9oStimz7IMtl7kp7WuTEKcUeD19c1SAUzMJsbAKp0Gxd+2uxji3IQOG7/0m9um
         T7RYqSQrQe8BWtx+kCYEluXhekhjcQJFPLb6nL60h6G5ne95zTle6PCFJwO5Dh2wY+15
         VkCDuk/EaXsLPn3I7Fq9EUkFd5dauxsrjAQwekocsqjdU6H8ibqbppNXk30HqAUAL0kY
         kVGndEglSVCbDh5P05fXiMufFimM1zmvydDKVBKEKSNz73A5EltZOe/nSxM/kFEL9ZVL
         isCepsx6AQMlbPb+qizHgI0ZAyHEhv4BIBbAwVR3/uyaBM0PYGp97uC0VmuEIz6R2z+i
         cx2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=+/C6EaNfq8gXsgMCYQEEr71KXJaPBdUxGSd0IfnMFlg=;
        b=LatPUWhWSE6h6rZzKykvlUWqXdTDm3oCVd2XHzjJrEA9x3wEJNNVxVqHTwdN/LPze6
         e/vlIT2F1iEfVtqDcWwzwmhOa2Wwzsnbmr0QVU0vLAUinT6Numx5jCA/gJT5dnUjupHA
         jpAINZJn4CyUzC+mTTo0cYKTj2Ls7M+KnqyWJbZjq9keA+BOS4AbwxsImKFKsp0OcR/M
         UYuudIOs2Pg8NO5IQswdAqbhf81sh8PBjMbDct5Mz32iyKmfi66XZn5BDz6ZkDdWbymN
         sK8lOSJZ7Mxqy0iRb4sxs+AzJ69/MXb0mSZv+JZM1iqcfZX2r/krlKeE6Aes5oDR2UAr
         Ozww==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=Yj9LduyX;
       spf=neutral (google.com: 66.111.4.26 is neither permitted nor denied by domain of penberg@iki.fi) smtp.mailfrom=penberg@iki.fi;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=iki.fi
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id u45si5195319qta.73.2019.02.12.23.32.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 23:32:41 -0800 (PST)
Received-SPF: neutral (google.com: 66.111.4.26 is neither permitted nor denied by domain of penberg@iki.fi) client-ip=66.111.4.26;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=Yj9LduyX;
       spf=neutral (google.com: 66.111.4.26 is neither permitted nor denied by domain of penberg@iki.fi) smtp.mailfrom=penberg@iki.fi;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=iki.fi
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id B3AEF21B55;
	Wed, 13 Feb 2019 02:32:40 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute4.internal (MEProxy); Wed, 13 Feb 2019 02:32:40 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:content-type
	:date:from:in-reply-to:message-id:mime-version:references
	:subject:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender
	:x-sasl-enc; s=fm2; bh=+/C6EaNfq8gXsgMCYQEEr71KXJaPBdUxGSd0IfnMF
	lg=; b=Yj9LduyXHslYA/Z15hx4F+BD9rpMYQe0GyOUczRGa0oq4CiMjFVoxHNeR
	iRBfQ+PkL085aBsS5OQA6H7iWl+Hf3WNeV3HYtIyefbIsrFhF1cjCoNIwLTOOf91
	V+N7wTMT2jJpy3vMqYEJM4FOX0t5u2reM4tUSqpizWoTLLLhZxcYIT5gY7ESWnp7
	hYgUFaqSzokVqZMHSrD6YfTLukZl53sl5aOwHaXS8qSj2xNKYz2oAq9EFRttLRHO
	MNpo5drdyFeDvRm64RnR7GxvpmzT1KVtQuwKIDxgq7im7oYvW41uniiH8pdnrSAx
	aWp65UCyad2yJC9zrLOK5ejloPScg==
X-ME-Sender: <xms:F8hjXJE1YfvwsBLDsCIcm8h3CsRZBFToz8djiyugQUWt0ov4QBjTYg>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledruddtvddgudduudcutefuodetggdotefrod
    ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthenuceurghilhhouhhtmecu
    fedttdenucenucfjughrpefuvfhfhffkffgfgggjtgfgsehtjeertddtfeejnecuhfhroh
    hmpefrvghkkhgrucfgnhgsvghrghcuoehpvghnsggvrhhgsehikhhirdhfiheqnecukfhp
    peekledrvdejrdeffedrudejfeenucfrrghrrghmpehmrghilhhfrhhomhepphgvnhgsvg
    hrghesihhkihdrfhhinecuvehluhhsthgvrhfuihiivgeptd
X-ME-Proxy: <xmx:F8hjXDCY4J0KLplMsgbReh1ul9H7rh2QsBr8v-8QvME3L9v3em1g7A>
    <xmx:F8hjXLZUilAPAMEFyP3qvI8cmDOyzpSWosbtbJnKWrDDOQuG26PvWg>
    <xmx:F8hjXDPSiYl7tKrgZgKflPCeUVhDaQC-5Mh0bh9PSLKBlb42PEcL5w>
    <xmx:GMhjXKWLRqKKSKgsQEXUAQaZd0uaXfHLh3j2TrwoNQfxWHB-X1n7mw>
Received: from Pekka-MacBook.local (89-27-33-173.bb.dnainternet.fi [89.27.33.173])
	by mail.messagingengine.com (Postfix) with ESMTPA id 91A47E412E;
	Wed, 13 Feb 2019 02:32:37 -0500 (EST)
Subject: Re: [PATCH] slub: untag object before slab end
To: Qian Cai <cai@lca.pw>, akpm@linux-foundation.org, cl@linux.com,
 penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com
Cc: andreyknvl@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <20190213020550.82453-1-cai@lca.pw>
From: Pekka Enberg <penberg@iki.fi>
Message-ID: <eeac3e54-c31a-a583-b185-b2d36d7debed@iki.fi>
Date: Wed, 13 Feb 2019 09:32:32 +0200
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:60.0)
 Gecko/20100101 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190213020550.82453-1-cai@lca.pw>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 13/02/2019 4.05, Qian Cai wrote:
> get_freepointer() could return NULL if there is no more free objects in
> the slab. However, it could return a tagged pointer (like
> 0x2200000000000000) with KASAN_SW_TAGS which would escape the NULL
> object checking in check_valid_pointer() and trigger errors below, so
> untag the object before checking for a NULL object there.

Reviewed-by: Pekka Enberg <penberg@kernel.org>

