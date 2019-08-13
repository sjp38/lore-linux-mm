Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1003DC433FF
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 09:16:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C3C1020679
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 09:16:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C3C1020679
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 74FCC6B026C; Tue, 13 Aug 2019 05:16:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6D9696B026D; Tue, 13 Aug 2019 05:16:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5C8646B026E; Tue, 13 Aug 2019 05:16:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0149.hostedemail.com [216.40.44.149])
	by kanga.kvack.org (Postfix) with ESMTP id 351176B026C
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 05:16:07 -0400 (EDT)
Received: from smtpin12.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id D1F62180AD7C1
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 09:16:06 +0000 (UTC)
X-FDA: 75816847932.12.hat77_6f7c8fb200a36
X-HE-Tag: hat77_6f7c8fb200a36
X-Filterd-Recvd-Size: 4284
Received: from mail-wm1-f67.google.com (mail-wm1-f67.google.com [209.85.128.67])
	by imf18.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 09:16:05 +0000 (UTC)
Received: by mail-wm1-f67.google.com with SMTP id f72so791945wmf.5
        for <linux-mm@kvack.org>; Tue, 13 Aug 2019 02:16:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:openpgp:message-id
         :date:user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=rJyEXL/9pmUa8F8Nq9N9p+VTELu7g73JrfbMzEYtsqw=;
        b=kPFSYaV5ocBxzJadPWH/NgvSVOTi2Ps6GgtLwHly932QzKnRar/9UqeiCYGyMLjw/W
         +TZYupVXJwunyrREMByH664oH1BmiWPx4QexHR13zucI/ERLcKgZGmfY2bRnHp0ZYF5Y
         9YJPVE/VtDF/wBsJI9kt4tnNkcbyM26KWrc6k3KK6pHsjHKDFtZVEHy92yftLTcFU2Er
         S9MvHS89zovoASJaRKxdHzLqzEZdEDRqd6D6jTOrrcwil6FluUEaFS71bYzJy8PgZlWS
         xRB1+WC5JBCFQQ08HD+oSwIz3HGpg+z7Iw0GRoLoRZXUr98ighGTg4W1380W0Q3j5HPk
         ycYQ==
X-Gm-Message-State: APjAAAXABsRP73+twMjAOho6k+qaleBaaosV968q6PilvVkmXEg0iQDA
	hIZGOXUJhBd130CHINHUm3Wasg==
X-Google-Smtp-Source: APXvYqwm309us5aZi/frD8eACHl5aijviV3HAVkqCeaBNsVD1mdnoZLmf1PImPsBNT+r6Tg0wB86fA==
X-Received: by 2002:a7b:cf0b:: with SMTP id l11mr2056631wmg.143.1565687764702;
        Tue, 13 Aug 2019 02:16:04 -0700 (PDT)
Received: from [192.168.10.150] ([93.56.166.5])
        by smtp.gmail.com with ESMTPSA id c15sm59116320wrb.80.2019.08.13.02.16.03
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Aug 2019 02:16:04 -0700 (PDT)
Subject: Re: [RFC PATCH v6 07/92] kvm: introspection: honor the reply option
 when handling the KVMI_GET_VERSION command
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
 <20190809160047.8319-8-alazar@bitdefender.com>
From: Paolo Bonzini <pbonzini@redhat.com>
Openpgp: preference=signencrypt
Message-ID: <a5cdbbd4-6f25-a0a5-054e-5810b5828a48@redhat.com>
Date: Tue, 13 Aug 2019 11:16:01 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190809160047.8319-8-alazar@bitdefender.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 09/08/19 17:59, Adalbert Laz=C4=83r wrote:
> Obviously, the KVMI_GET_VERSION command must not be used when the comma=
nd
> reply is disabled by a previous KVMI_CONTROL_CMD_RESPONSE command.
>=20
> This commit changes the code path in order to check the reply option
> (enabled/disabled) before trying to reply to this command. If the comma=
nd
> reply is disabled it will return an error to the caller. In the end, th=
e
> receiving worker will finish and the introspection socket will be close=
d.
>=20
> Signed-off-by: Adalbert Laz=C4=83r <alazar@bitdefender.com>
> ---
>  virt/kvm/kvmi_msg.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/virt/kvm/kvmi_msg.c b/virt/kvm/kvmi_msg.c
> index ea5c7e23669a..2237a6ed25f6 100644
> --- a/virt/kvm/kvmi_msg.c
> +++ b/virt/kvm/kvmi_msg.c
> @@ -169,7 +169,7 @@ static int handle_get_version(struct kvmi *ikvm,
>  	memset(&rpl, 0, sizeof(rpl));
>  	rpl.version =3D KVMI_VERSION;
> =20
> -	return kvmi_msg_vm_reply(ikvm, msg, 0, &rpl, sizeof(rpl));
> +	return kvmi_msg_vm_maybe_reply(ikvm, msg, 0, &rpl, sizeof(rpl));
>  }
> =20
>  static bool is_command_allowed(struct kvmi *ikvm, int id)
>=20

Go ahead and squash this in the previous patch.

Paolo

