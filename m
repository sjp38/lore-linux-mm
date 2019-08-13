Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CCD83C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 08:44:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 95258206C2
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 08:44:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 95258206C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2D3AD6B0005; Tue, 13 Aug 2019 04:44:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 285026B0007; Tue, 13 Aug 2019 04:44:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1C1D76B0008; Tue, 13 Aug 2019 04:44:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0245.hostedemail.com [216.40.44.245])
	by kanga.kvack.org (Postfix) with ESMTP id EDE1D6B0005
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 04:44:32 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 8E44D180AD7C1
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 08:44:32 +0000 (UTC)
X-FDA: 75816768384.28.flag96_7eeb894f6b32e
X-HE-Tag: flag96_7eeb894f6b32e
X-Filterd-Recvd-Size: 4413
Received: from mail-wr1-f68.google.com (mail-wr1-f68.google.com [209.85.221.68])
	by imf49.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 08:44:32 +0000 (UTC)
Received: by mail-wr1-f68.google.com with SMTP id q12so16702986wrj.12
        for <linux-mm@kvack.org>; Tue, 13 Aug 2019 01:44:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:openpgp:message-id
         :date:user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=blKE7hBPEaF3XcD8274I5hmyBZ0ZERzbpulCfit8yl4=;
        b=UjZFhOogYWJ+4wVGqZPjUqWCTLLcnW/dKABpq3Ya/6+o97TwDBK2m1LwJKb64mg2jB
         jIZ3F5eyxOu7PBmJkvNTVGYqe0aUQr+4BNFFxrKGl9MK6x8tyVhvBfw1RSHA1gkwvpcx
         IndF/Q0/eOWm485HNbvIMuwKcptwSeVwznTwy8lRdxYd99VVHHUmwR3nxQ5onQP8uQIf
         zyZ3cm0m807eG+ySTkZ+eyxd4bOxG9wZ+4g8xwl5kREHd9QuV7PwcvWIR5WiwKyBaEjD
         FwdWXcTa7F5b3GYon0c2V5RG5hVNPuBxPJNuY6jn37c4/cmnOIHiq5yw/2m093cDNb/P
         IUxQ==
X-Gm-Message-State: APjAAAVc3Pr52zBgzDXMrEBuuG8ZimaOyMJYcuwSKEQyFQGB/6Vofnma
	olVrGrR3zIdf8zmDDWoL+lyqug==
X-Google-Smtp-Source: APXvYqw492WjaEpNzhoTXs/Gd2KelQnitfzJEsecNo1teLr2zcjaHoX7vjpPsoanUMoKR8v6ysgEKw==
X-Received: by 2002:a5d:490a:: with SMTP id x10mr42031164wrq.152.1565685870989;
        Tue, 13 Aug 2019 01:44:30 -0700 (PDT)
Received: from [192.168.10.150] ([93.56.166.5])
        by smtp.gmail.com with ESMTPSA id o126sm1401625wmo.1.2019.08.13.01.44.29
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Aug 2019 01:44:30 -0700 (PDT)
Subject: Re: [RFC PATCH v6 02/92] kvm: introspection: add basic ioctls
 (hook/unhook)
To: =?UTF-8?Q?Adalbert_Laz=c4=83r?= <alazar@bitdefender.com>,
 kvm@vger.kernel.org
Cc: linux-mm@kvack.org, virtualization@lists.linux-foundation.org,
 =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>,
 Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 Tamas K Lengyel <tamas@tklengyel.com>,
 Mathieu Tarral <mathieu.tarral@protonmail.com>,
 =?UTF-8?Q?Samuel_Laur=c3=a9n?= <samuel.lauren@iki.fi>,
 Patrick Colp <patrick.colp@oracle.com>, Jan Kiszka <jan.kiszka@siemens.com>,
 Stefan Hajnoczi <stefanha@redhat.com>,
 Weijiang Yang <weijiang.yang@intel.com>, Yu C Zhang <yu.c.zhang@intel.com>,
 =?UTF-8?Q?Mihai_Don=c8=9bu?= <mdontu@bitdefender.com>,
 =?UTF-8?Q?Mircea_C=c3=aerjaliu?= <mcirjaliu@bitdefender.com>
References: <20190809160047.8319-1-alazar@bitdefender.com>
 <20190809160047.8319-3-alazar@bitdefender.com>
From: Paolo Bonzini <pbonzini@redhat.com>
Openpgp: preference=signencrypt
Message-ID: <58808ef0-57b1-47ac-a115-e1dd64a15b0a@redhat.com>
Date: Tue, 13 Aug 2019 10:44:28 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190809160047.8319-3-alazar@bitdefender.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 09/08/19 17:59, Adalbert Laz=C4=83r wrote:
> +static int kvmi_recv(void *arg)
> +{
> +	struct kvmi *ikvm =3D arg;
> +
> +	kvmi_info(ikvm, "Hooking VM\n");
> +
> +	while (kvmi_msg_process(ikvm))
> +		;
> +
> +	kvmi_info(ikvm, "Unhooking VM\n");
> +
> +	kvmi_end_introspection(ikvm);
> +
> +	return 0;
> +}
> +

Rename this to kvmi_recv_thread instead, please.

> +
> +	/*
> +	 * Make sure all the KVM/KVMI structures are linked and no pointer
> +	 * is read as NULL after the reference count has been set.
> +	 */
> +	smp_mb__before_atomic();

This is an smp_wmb(), not an smp_mb__before_atomic().  Add a comment
that it pairs with the refcount_inc_not_zero in kvmi_get.

> +	refcount_set(&kvm->kvmi_ref, 1);
> +


> @@ -57,8 +183,27 @@ void kvmi_destroy_vm(struct kvm *kvm)
>  	if (!ikvm)
>  		return;
> =20
> +	/* trigger socket shutdown - kvmi_recv() will start shutdown process =
*/
> +	kvmi_sock_shutdown(ikvm);
> +
>  	kvmi_put(kvm);
> =20
>  	/* wait for introspection resources to be released */
>  	wait_for_completion_killable(&kvm->kvmi_completed);
>  }
> +

This addition means that kvmi_destroy_vm should have called
kvmi_end_introspection instead.  In patch 1, kvmi_end_introspection
should have been just kvmi_put, now this patch can add kvmi_sock_shutdown=
.

Paolo

