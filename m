Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 837D36B0038
	for <linux-mm@kvack.org>; Thu, 10 Sep 2015 05:13:13 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so16236943wic.1
        for <linux-mm@kvack.org>; Thu, 10 Sep 2015 02:13:12 -0700 (PDT)
Received: from eu-smtp-delivery-143.mimecast.com (eu-smtp-delivery-143.mimecast.com. [207.82.80.143])
        by mx.google.com with ESMTPS id si6si5281895wic.33.2015.09.10.02.13.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 10 Sep 2015 02:13:12 -0700 (PDT)
Date: Thu, 10 Sep 2015 10:13:07 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH 1/1] mm: kmemleak: remove unneeded initialization of
 object to NULL
Message-ID: <20150910091306.GB12294@localhost>
References: <1441838029-4596-1-git-send-email-alexey.klimov@linaro.org>
MIME-Version: 1.0
In-Reply-To: <1441838029-4596-1-git-send-email-alexey.klimov@linaro.org>
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Klimov <alexey.klimov@linaro.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, klimov.linux@gmail.com

On Thu, Sep 10, 2015 at 01:33:49AM +0300, Alexey Klimov wrote:
> Few lines below object is reinitialized by lookup_object()
> so we don't need to init it by NULL in the beginning of
> find_and_get_object().
>=20
> Signed-off-by: Alexey Klimov <alexey.klimov@linaro.org>

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
