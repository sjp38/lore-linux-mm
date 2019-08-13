Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D543BC433FF
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 09:15:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 99ACB20843
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 09:15:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 99ACB20843
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4DFAB6B026B; Tue, 13 Aug 2019 05:15:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 468C86B026C; Tue, 13 Aug 2019 05:15:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3304D6B026D; Tue, 13 Aug 2019 05:15:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0003.hostedemail.com [216.40.44.3])
	by kanga.kvack.org (Postfix) with ESMTP id 0BF436B026B
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 05:15:44 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id A6752181AC9AE
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 09:15:43 +0000 (UTC)
X-FDA: 75816846966.05.bite18_6c2b7ba423c26
X-HE-Tag: bite18_6c2b7ba423c26
X-Filterd-Recvd-Size: 4289
Received: from mail-wr1-f67.google.com (mail-wr1-f67.google.com [209.85.221.67])
	by imf49.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 09:15:43 +0000 (UTC)
Received: by mail-wr1-f67.google.com with SMTP id k2so21209793wrq.2
        for <linux-mm@kvack.org>; Tue, 13 Aug 2019 02:15:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:openpgp:message-id
         :date:user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=q7bgqMdQ4an3+fW9pjXHTss4SNTSFngzufR2wW+436s=;
        b=oC9nyl5WrPI0mUxTLlLLMoD4+N/Fk8j10tMgQRDDZ+bzDA001OQswzkfs0O7lo8FEO
         8uh5HpNfhx6ky065unA9agZFkz9G9Fp66BiplO4OwLtSPOIYYWPopw9Enwjb6wrPJ/an
         /7dhCXy+sglRiJfLEt9hMVgypMKL7nOWdwFIFLAZkl0QKJ8EX9wbGE9m+fKF27NfTKXp
         CYFTQksQbl+/t6TNm0m9+o+gYdOvz4KPUoJ6QxLjzZO4LNEG8eyeN9wOV6WJt2G8xcwA
         Uvda+g7stJ70dSuEXuflxlCBUSuhPwhLPQq2d4GVbbZSRwkCYHePYsMTb9tT1WEkmEWw
         SfKw==
X-Gm-Message-State: APjAAAUdnu/s6CMTIKLf9vALGWoJ8+ZY0Q+Dr5H5WrX+iT6sGopmFXYA
	mXNTivZFnEEJwUtuGgkUZTiJ/w==
X-Google-Smtp-Source: APXvYqxstOWD8uGBtXH2sZT96q5cW3boODxMOIYCbZ+H7TsBnLr+a/3ZIecGYglK7JULc1kUyTstKQ==
X-Received: by 2002:adf:dc0f:: with SMTP id t15mr25505581wri.50.1565687742155;
        Tue, 13 Aug 2019 02:15:42 -0700 (PDT)
Received: from [192.168.10.150] ([93.56.166.5])
        by smtp.gmail.com with ESMTPSA id w5sm914921wmm.43.2019.08.13.02.15.40
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Aug 2019 02:15:41 -0700 (PDT)
Subject: Re: [RFC PATCH v6 06/92] kvm: introspection: add
 KVMI_CONTROL_CMD_RESPONSE
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
 =?UTF-8?Q?Mihai_Don=c8=9bu?= <mdontu@bitdefender.com>
References: <20190809160047.8319-1-alazar@bitdefender.com>
 <20190809160047.8319-7-alazar@bitdefender.com>
From: Paolo Bonzini <pbonzini@redhat.com>
Openpgp: preference=signencrypt
Message-ID: <e8f59b08-734a-2ce1-ae28-3cc9d90c0bcb@redhat.com>
Date: Tue, 13 Aug 2019 11:15:34 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190809160047.8319-7-alazar@bitdefender.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 09/08/19 17:59, Adalbert Laz=C4=83r wrote:
> +If `now` is 1, the command reply is enabled/disabled (according to
> +`enable`) starting with the current command. For example, `enable=3D0`
> +and `now=3D1` means that the reply is disabled for this command too,
> +while `enable=3D0` and `now=3D0` means that a reply will be send for t=
his
> +command, but not for the next ones (until enabled back with another
> +*KVMI_CONTROL_CMD_RESPONSE*).
> +
> +This command is used by the introspection tool to disable the replies
> +for commands returning an error code only (eg. *KVMI_SET_REGISTERS*)
> +when an error is less likely to happen. For example, the following
> +commands can be used to reply to an event with a single `write()` call=
:
> +
> +	KVMI_CONTROL_CMD_RESPONSE enable=3D0 now=3D1
> +	KVMI_SET_REGISTERS vcpu=3DN
> +	KVMI_EVENT_REPLY   vcpu=3DN
> +	KVMI_CONTROL_CMD_RESPONSE enable=3D1 now=3D0

I don't understand the usage.  Is there any case where you want now =3D=3D=
 1
actually?  Can you just say that KVMI_CONTROL_CMD_RESPONSE never has a
reply, or to make now=3D=3Denable?

> +	if (err)
> +		kvmi_warn(ikvm, "Error code %d discarded for message id %d\n",
> +			  err, msg->id);
> +

Would it make sense to even close the socket if there is an error?

Paolo

