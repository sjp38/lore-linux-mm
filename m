Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id CFCC76B0005
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 18:05:49 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id g63-v6so12199469pfc.9
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 15:05:49 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id f11-v6si19857812pgr.65.2018.10.17.15.05.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Oct 2018 15:05:48 -0700 (PDT)
Date: Wed, 17 Oct 2018 15:05:46 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] serial: set suppress_bind_attrs flag only if
 builtin
Message-Id: <20181017150546.0d451252950214bec74a6fc8@linux-foundation.org>
In-Reply-To: <20181017140311.28679-1-anders.roxell@linaro.org>
References: <20181017140311.28679-1-anders.roxell@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anders Roxell <anders.roxell@linaro.org>
Cc: linux@armlinux.org.uk, gregkh@linuxfoundation.org, linux-serial@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, tj@kernel.org, Arnd Bergmann <arnd@arndb.de>

On Wed, 17 Oct 2018 16:03:10 +0200 Anders Roxell <anders.roxell@linaro.org> wrote:

> Cc: Arnd Bergmann <arnd@arndb.de>
> Co-developed-by: Arnd Bergmann <arnd@arndb.de>
> Signed-off-by: Anders Roxell <anders.roxell@linaro.org>

This should have Arnd's Signed-off-by: as well.
