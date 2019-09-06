Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 604A2C43331
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 19:04:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 276DD207FC
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 19:04:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="LeW70Cwz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 276DD207FC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CD44C6B000D; Fri,  6 Sep 2019 15:04:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C839A6B000E; Fri,  6 Sep 2019 15:04:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B724A6B0010; Fri,  6 Sep 2019 15:04:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0238.hostedemail.com [216.40.44.238])
	by kanga.kvack.org (Postfix) with ESMTP id 94C0C6B000D
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 15:04:54 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 363F1180AD801
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 19:04:54 +0000 (UTC)
X-FDA: 75905422908.18.food87_64f283cda9f40
X-HE-Tag: food87_64f283cda9f40
X-Filterd-Recvd-Size: 3677
Received: from mail-ed1-f68.google.com (mail-ed1-f68.google.com [209.85.208.68])
	by imf28.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 19:04:53 +0000 (UTC)
Received: by mail-ed1-f68.google.com with SMTP id y91so7234345ede.9
        for <linux-mm@kvack.org>; Fri, 06 Sep 2019 12:04:53 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=jojg3lt9aotJnGt5bH33wsrcyv/EEKP9KJRLMGkqesY=;
        b=LeW70Cwz4yP0y+LnTrM6vdUtvCMHjSw1acep3zXSJpi5BYck+TcuH8lwg6BFF+angS
         RDYMTGCVx+3iLx4bIRpfNA69sQlUdbjAfJrE1tIJt9h5xR7KlD59f1teg2zUjKLWji8U
         HtKOfDiAs4fvtxuIYAkhN86SzJ/3DECTbwuraae7Ro4Fnmf/j7wRycV3GekLevRvA4yi
         hN+l2NlmZ43f8LnS3649b2RQBq2URKwBrG03uECmpal6VX2gf/H7cIiJydxgVHNdAVEK
         ZsN2k2L3TJXN4FJXJv8Ww2KRqLaR8luX0x/QO6p8DnbYTUm/7XaIdegqHhHY71r0jRUC
         LkWg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=jojg3lt9aotJnGt5bH33wsrcyv/EEKP9KJRLMGkqesY=;
        b=PRH5L2tfgruR++2omrWh11QLJCo93Yyj90rEg/P/Pysxo1GYbmAmNxyqGyP+V/hR4x
         fahTbL9iEuLAhRwOlhh1npYg+K2IWHMohaKh0GvPrUpVX+XaDCa9g1iKtPt/ja/L9lVM
         5or+9J7oEIs33rPw9e1vcCW3lQPhX0VZeJWktzWW5OLU5aAhAK05E16O713+YAUbqggx
         fPNAfSVDYyQNw2Tj5gotkgL9iQRI3kc0czdOkvtYsz1kVEDFiak8hBUhNWfN74SGcs/V
         EJBtPlcVrGyUsysDlB4/Nvm4vHEdDyBkxYXqT9lMmRVp6V1HWoazpJasJpj808eaMs6l
         3G2Q==
X-Gm-Message-State: APjAAAVSZrhJk+SbKhYbqAI3QFIwy9yjubcZNE2f0RV1z/dkYK/snuBC
	xNHRefydiI98LSq+/LZ9kL7aGFuTkXq47Fog3A95iA==
X-Google-Smtp-Source: APXvYqyK1SCAqBB23XwDsQMDwIBa7uh8HdAPqm1/xVvjPDxouORMX2W/oKEVAMQ70bEUmrEuPn+OtVr0upjiCbgyF4o=
X-Received: by 2002:aa7:c40c:: with SMTP id j12mr11447072edq.80.1567796692440;
 Fri, 06 Sep 2019 12:04:52 -0700 (PDT)
MIME-Version: 1.0
References: <20190821183204.23576-1-pasha.tatashin@soleen.com>
 <20190821183204.23576-12-pasha.tatashin@soleen.com> <d53d973c-17dc-2f4f-c052-83d6df15b002@arm.com>
In-Reply-To: <d53d973c-17dc-2f4f-c052-83d6df15b002@arm.com>
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Fri, 6 Sep 2019 15:04:41 -0400
Message-ID: <CA+CK2bCSDEspfJZ9k_4nWmerQSatc9M_dVf4Jij5xUwTMbg29w@mail.gmail.com>
Subject: Re: [PATCH v3 11/17] arm64, trans_pgd: add PUD_SECT_RDONLY
To: James Morse <james.morse@arm.com>
Cc: James Morris <jmorris@namei.org>, Sasha Levin <sashal@kernel.org>, 
	"Eric W. Biederman" <ebiederm@xmission.com>, kexec mailing list <kexec@lists.infradead.org>, 
	LKML <linux-kernel@vger.kernel.org>, Jonathan Corbet <corbet@lwn.net>, 
	Catalin Marinas <catalin.marinas@arm.com>, will@kernel.org, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>, Marc Zyngier <marc.zyngier@arm.com>, 
	Vladimir Murzin <vladimir.murzin@arm.com>, Matthias Brugger <matthias.bgg@gmail.com>, 
	Bhupesh Sharma <bhsharma@redhat.com>, linux-mm <linux-mm@kvack.org>, 
	Mark Rutland <mark.rutland@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Sep 6, 2019 at 11:21 AM James Morse <james.morse@arm.com> wrote:
>
> Hi Pavel,
>
> On 21/08/2019 19:31, Pavel Tatashin wrote:
> > Thre is PMD_SECT_RDONLY that is used in pud_* function which is confusing.
>
> Nit: There
>
> I bet it was equally confusing before before you moved it! Could you do this earlier in
> the series with the rest of the cleanup?
>
> With that,
> Acked-by: James Morse <james.morse@arm.com>

Will move it earlier.

Thank you,
Pasha

