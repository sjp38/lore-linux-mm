Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C241AC4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 15:45:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6921F206BA
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 15:45:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="fNKVdLeG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6921F206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0766B6B026A; Wed,  3 Apr 2019 11:45:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0268B6B027B; Wed,  3 Apr 2019 11:45:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E7E796B027C; Wed,  3 Apr 2019 11:45:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id CF0386B026A
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 11:45:38 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id n13so17062747qtn.6
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 08:45:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=S3KEpUyvqM6uvSTVOlaUBjSIeihlWd1TPi8ErfosSE0=;
        b=j22+6Xw+qR8L76+w4moIz97J1gWWc6F5k61Lb4p5zupkn8uxVetigg3DLNngRODrjr
         nC0tnPVnI/pfHAIc+q6ylcD3Zf21WS1bVWNOZW0Tu+X5Xl4/lG4uVKdbypOrnWjFtCn0
         KyTHIIi9P5WHkjAaYl4r+v3XnL1UFDUXAoBKJdx7rpzXEo9/FPqvTNAy1fyJ/S0Q+inL
         akd8feicYNaoYitgigcxuQHmH5QCY4gkIK7wfOgmar5nAVKBotY+26UvSoNNvb3SVDL0
         i24vaw/OvnUQZRG18SSqzoD6b3rlKB5Vx+QiOWh6C4O4SGnYz5904HDGv0RKtNd318bW
         HcCA==
X-Gm-Message-State: APjAAAVtB0vv5MOUJ2lmVfigRo9Dx9jsTkqNyo5uaQNS9Ie1jtuSxpRg
	PsrcwfCpvC+GcnMXBNkRZSxoKlZIdJ3ALhLZ/D2pkXXiV7aXl9yHw7HTxs137qUC1cbyVTua42H
	OHknQ0LKAzT+SiwpsmKv0kvX296XC1TF0bwl6MpSQdM67F7uWLEesxu+Rp20Dlsk=
X-Received: by 2002:ae9:f809:: with SMTP id x9mr610621qkh.215.1554306338592;
        Wed, 03 Apr 2019 08:45:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxhKEq9H8Yt5hhAody8L2uh7PzfOpshgNN/Wd2cBpbDcQHJlC+QCMFXRIQ4xtfmpbfneeyH
X-Received: by 2002:ae9:f809:: with SMTP id x9mr610562qkh.215.1554306337807;
        Wed, 03 Apr 2019 08:45:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554306337; cv=none;
        d=google.com; s=arc-20160816;
        b=Scrn7w4MFpEuYvBgFywWpc4uyEQunl+wVEBawxrCLnD7+XacG1xySoSQhVVOFD9y6x
         Ccg1UnMxO6rN3H3+xmoNE1VjTcULoFKl+jJLD6NLYk1j0p6bH4qZ942UH+VEpvUfIVlf
         35s68xxJAqLbDlTZw/RA6dBGSar2jBiqeZZh7BariSujDcOILm3yy0AezozRTTh0U3Mp
         TOLUP4iJo4j6i9F7RzIeioY+n56dhh0qDhyv63HZpnLt0JaUNSzqRWNm0gx8aqsSwNPE
         Ci58+YOqWxXU1FsZ67AVFgxphMUoNyoe4tPOHXl3H0aNi3GlHWHkMetDjlZlIYWuIhFI
         RJEQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=S3KEpUyvqM6uvSTVOlaUBjSIeihlWd1TPi8ErfosSE0=;
        b=mNB2OwcHXOWMFyeAW67k9BGm1G5dNXiw1diP3uKAyobmsHpkRWrGyeMHLORtoP0fPv
         Fjl/1yx0QLwusCfmkjVesrzLcWaMZY8/QBWy3L7ZWsU3J1YsvZUKmDjH6UrNRm3xcG26
         1WJBmiz8Iyj0fd5si6BvtRu+sYal6/aD30spetQBM7qUD1q7pWveeqZ7FQIndm8UFfRg
         3oZfHeBhsN/Wg56p9/NcWJbXkvzBK2kDBkQhbuJ7DK9a34C5FtqaY8pdH4IO9DpwotfY
         Mm3Ev9wHybU8iZRtMzFNv5oJ4/SsPZtvUhq7S6owe5PCQrsNsRDcoyglrZmUQkU9LXJ/
         FBxQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=fNKVdLeG;
       spf=pass (google.com: domain of 01000169e3e08a01-cd8427e0-3671-4263-870f-98cb4741f10d-000000@amazonses.com designates 54.240.9.99 as permitted sender) smtp.mailfrom=01000169e3e08a01-cd8427e0-3671-4263-870f-98cb4741f10d-000000@amazonses.com
Received: from a9-99.smtp-out.amazonses.com (a9-99.smtp-out.amazonses.com. [54.240.9.99])
        by mx.google.com with ESMTPS id n42si7736210qtk.70.2019.04.03.08.45.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 03 Apr 2019 08:45:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of 01000169e3e08a01-cd8427e0-3671-4263-870f-98cb4741f10d-000000@amazonses.com designates 54.240.9.99 as permitted sender) client-ip=54.240.9.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=fNKVdLeG;
       spf=pass (google.com: domain of 01000169e3e08a01-cd8427e0-3671-4263-870f-98cb4741f10d-000000@amazonses.com designates 54.240.9.99 as permitted sender) smtp.mailfrom=01000169e3e08a01-cd8427e0-3671-4263-870f-98cb4741f10d-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1554306337;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=Eh1VbaI4wezMKlsjcm5vyrOc3cPM6V0fDLZmVvAIr84=;
	b=fNKVdLeGoDup3EZR/C4+OUJ/1ngF37rhYt3ZVYWZq/X1pIzll+jaBCKskTzvxnYl
	fpEWz9k+s0ALrbAR2XjNoHsVKK/LuTsvclHrUiXraqaOXoB6fsH+IqIFR+sI34Ew3tC
	CjhahnUGM6G70tmFWpZufQyFNj9Q+N5Q5iZBwxbs=
Date: Wed, 3 Apr 2019 15:45:37 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: "Tobin C. Harding" <tobin@kernel.org>
cc: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, 
    Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, 
    Joonsoo Kim <iamjoonsoo.kim@lge.com>, Matthew Wilcox <willy@infradead.org>, 
    linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v5 2/7] slob: Respect list_head abstraction layer
In-Reply-To: <20190402230545.2929-3-tobin@kernel.org>
Message-ID: <01000169e3e08a01-cd8427e0-3671-4263-870f-98cb4741f10d-000000@email.amazonses.com>
References: <20190402230545.2929-1-tobin@kernel.org> <20190402230545.2929-3-tobin@kernel.org>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.04.03-54.240.9.99
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 3 Apr 2019, Tobin C. Harding wrote:

> Currently we reach inside the list_head.  This is a violation of the
> layer of abstraction provided by the list_head.  It makes the code
> fragile.  More importantly it makes the code wicked hard to understand.

Great.... It definitely makes it clearer. The boolean parameter is not
so nice but I have no idea how to avoid it in the brief time I spent
looking at it.

Acked-by: Christoph Lameter <cl@linux.com>

