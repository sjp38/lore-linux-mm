Return-Path: <SRS0=SJ39=PZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 07360C43387
	for <linux-mm@archiver.kernel.org>; Thu, 17 Jan 2019 17:42:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C4CD820652
	for <linux-mm@archiver.kernel.org>; Thu, 17 Jan 2019 17:42:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C4CD820652
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5F8038E000D; Thu, 17 Jan 2019 12:42:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5A6718E0002; Thu, 17 Jan 2019 12:42:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4BD418E000D; Thu, 17 Jan 2019 12:42:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1DF2A8E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 12:42:41 -0500 (EST)
Received: by mail-oi1-f198.google.com with SMTP id r131so3635405oia.7
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 09:42:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=4l33NxMborqisvl0/5peQNrXL5/jqVOWTyG/TbJwZME=;
        b=XLkFIJouPvB+VD3M+RanPQVuRxmHgOW1ASsN0oNie3pOMgeQOoCAX8/iHLmmFDlknM
         9Dz/TGJKUcm5sZ4e/R9L2ApZNuk+3JW/Y9X828x+Ztbb3pbRyRJZMaTL2faLnXUTsxbZ
         iTvhwuo6rq8pakGwk+f232uTytO5sKNPHAJQZAX7uqq/YKEwqYhEA2pqKtwq87N7XFl3
         BXL+Q2eId1lAOmTzIEvX/j+3hMNucsitDec8niAlVoYYmaocW8VZqdxZVyLOqrpOz1FA
         w9voavmVPiWK+1q9XnOUShoW4XF3XQ50q1VlejLgIZgfSsJaLVcTni01iOccxfYdBSDt
         UHDA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukdiwviWSFJC762jCzG8Bj6yPx3PfUYDML2OqRhJ1KjdPwER7H2y
	x2zgQuNni1Jx8OjDX9TGMOHALs0pmP6QDt55Z6VQRo016OlIdPZ7jNbXeusnWbYybd+3BLBdtZe
	QcafA5Xr4JTHkNG4wp8ZvGYX6r6v7GQuHPH+Ax6ubgZYavvGb6hYga0RjwLCbndmbuBpvZAYa8N
	8hra9HK36SzKiLGZ2G6G5iW5ByjDkr+HObSxknc4ZSCKGSuf2FCKDKF3BAZUU2K2k62g59FPiBZ
	vkph3jwOOT/aPhS9g1Sm1MfFmVzTTvup693Og8Amd3mOlHdg8AtEiDpiY2GXAZ9PRaOHshY1Ago
	KWkIcMN4/4ESKhdBppZsM3W6BcaaPX9tbhQu7jJywmD/QSKajG1XwDjmhx7b19mhrgwIQ6v4RA=
	=
X-Received: by 2002:a9d:2184:: with SMTP id s4mr10008654otb.46.1547746960827;
        Thu, 17 Jan 2019 09:42:40 -0800 (PST)
X-Received: by 2002:a9d:2184:: with SMTP id s4mr10008631otb.46.1547746960192;
        Thu, 17 Jan 2019 09:42:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547746960; cv=none;
        d=google.com; s=arc-20160816;
        b=PGMSJuPQdOJ2qBtjMgSzkFKuOvZdWG493JhmyiLwFJspJANWnW3AFYU5h8eZf1YR0l
         J0gRFKnQsm1zUjRQZSORyMoRZbGT0h1HsgcueH6guzYUwshAtCoHJXm9oj3OEvvq4eO9
         QssSPiErvIWSKXV2Wv1u43ODC7iJUEL1ajHzd8MrdOBP7D1gMIceUKjO4MF5cHmh45jl
         EjUY0FWxvV215ecOItky3djEdua206ED6TFsLzngCDMy7/JNQQSAyA/580nAyQ0GZPKS
         j2LfAMHb8EXhtqNFKGz7mJH3nyzwJtul2oHwk+lcZryuPCdoUR8qwLnu2yF+nakkSZvd
         tGkQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=4l33NxMborqisvl0/5peQNrXL5/jqVOWTyG/TbJwZME=;
        b=1E7Fkqns1UCKrsElKZ1RHFPe+hLgttEdRXS9L9cEN+S2xD0+xOEAdEeNiQlCppQIaw
         bqNIMjgf2Cbf27ZOeIU+3D6QVA1plNj1FmlEOT8V7e9f9jHXygn2PxEglw226CUeQpBR
         Gz97xTCeGdoFtzvL7feSepLJ7Otn1NkhIw6FIogcG54hvayrJCGyL+FYBqRz+yc5fAt8
         lUkQ1+gQvDxdc08jmU+ESeCvR1yruemq7/ZMPRLbxAzAtDLpb6kkpinADjnF5VkYWuHX
         7YGS/idusspXS75ZYX4pBr2JnOEQcKPwbugb9KGMh2TtEDOP1dH2qU9H0z1d9MM7bcZH
         FAJQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f14sor1273415oib.5.2019.01.17.09.42.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 17 Jan 2019 09:42:40 -0800 (PST)
Received-SPF: pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: ALg8bN7ZCZU/M8Gzd8tnGaTDyfYGJojPLIitPj6v3VkC0twTsbGW6IJGM7rdOn0kPv0Uyd6CHY/HLFmXvHO4LC8BfTc=
X-Received: by 2002:aca:195:: with SMTP id 143mr5537206oib.322.1547746959614;
 Thu, 17 Jan 2019 09:42:39 -0800 (PST)
MIME-Version: 1.0
References: <20190116175804.30196-1-keith.busch@intel.com> <20190116175804.30196-13-keith.busch@intel.com>
In-Reply-To: <20190116175804.30196-13-keith.busch@intel.com>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Thu, 17 Jan 2019 18:42:28 +0100
Message-ID:
 <CAJZ5v0gu0zcyZtHv4mDioS6j4WMsz_59bYdzuGtOPXfKVNOX+g@mail.gmail.com>
Subject: Re: [PATCHv4 12/13] acpi/hmat: Register memory side cache attributes
To: Keith Busch <keith.busch@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
	ACPI Devel Maling List <linux-acpi@vger.kernel.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, 
	Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190117174228.mHhmVZJQTqlsNuP3pqZH3eqpzPHNyvGtdCgvyV6JEn0@z>

On Wed, Jan 16, 2019 at 6:59 PM Keith Busch <keith.busch@intel.com> wrote:
>
> Register memory side cache attributes with the memory's node if HMAT
> provides the side cache iniformation table.
>
> Signed-off-by: Keith Busch <keith.busch@intel.com>
> ---
>  drivers/acpi/hmat/hmat.c | 32 ++++++++++++++++++++++++++++++++
>  1 file changed, 32 insertions(+)
>
> diff --git a/drivers/acpi/hmat/hmat.c b/drivers/acpi/hmat/hmat.c
> index 45e20dc677f9..9efdd0a63a79 100644
> --- a/drivers/acpi/hmat/hmat.c
> +++ b/drivers/acpi/hmat/hmat.c
> @@ -206,6 +206,7 @@ static __init int hmat_parse_cache(union acpi_subtable_headers *header,
>                                    const unsigned long end)
>  {
>         struct acpi_hmat_cache *cache = (void *)header;
> +       struct node_cache_attrs cache_attrs;
>         u32 attrs;
>
>         if (cache->header.length < sizeof(*cache)) {
> @@ -219,6 +220,37 @@ static __init int hmat_parse_cache(union acpi_subtable_headers *header,
>                 cache->memory_PD, cache->cache_size, attrs,
>                 cache->number_of_SMBIOShandles);
>
> +       cache_attrs.size = cache->cache_size;
> +       cache_attrs.level = (attrs & ACPI_HMAT_CACHE_LEVEL) >> 4;
> +       cache_attrs.line_size = (attrs & ACPI_HMAT_CACHE_LINE_SIZE) >> 16;
> +
> +       switch ((attrs & ACPI_HMAT_CACHE_ASSOCIATIVITY) >> 8) {
> +       case ACPI_HMAT_CA_DIRECT_MAPPED:
> +               cache_attrs.associativity = NODE_CACHE_DIRECT_MAP;
> +               break;
> +       case ACPI_HMAT_CA_COMPLEX_CACHE_INDEXING:
> +               cache_attrs.associativity = NODE_CACHE_INDEXED;
> +               break;
> +       case ACPI_HMAT_CA_NONE:
> +       default:

This looks slightly odd as "default" covers the other case as well.
Maybe say what other case is covered by "default" in particular in a
comment?

> +               cache_attrs.associativity = NODE_CACHE_OTHER;
> +               break;
> +       }
> +
> +       switch ((attrs & ACPI_HMAT_WRITE_POLICY) >> 12) {
> +       case ACPI_HMAT_CP_WB:
> +               cache_attrs.write_policy = NODE_CACHE_WRITE_BACK;
> +               break;
> +       case ACPI_HMAT_CP_WT:
> +               cache_attrs.write_policy = NODE_CACHE_WRITE_THROUGH;
> +               break;
> +       case ACPI_HMAT_CP_NONE:
> +       default:

And analogously here.

> +               cache_attrs.write_policy = NODE_CACHE_WRITE_OTHER;
> +               break;
> +       }
> +
> +       node_add_cache(pxm_to_node(cache->memory_PD), &cache_attrs);
>         return 0;
>  }
>
> --

