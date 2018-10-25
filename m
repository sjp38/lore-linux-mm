Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1A0106B02BB
	for <linux-mm@kvack.org>; Thu, 25 Oct 2018 15:42:53 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 14-v6so7916831pfk.22
        for <linux-mm@kvack.org>; Thu, 25 Oct 2018 12:42:53 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id u5-v6si9131571pgm.268.2018.10.25.12.42.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Oct 2018 12:42:52 -0700 (PDT)
Date: Thu, 25 Oct 2018 12:42:49 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] z3fold: encode object length in the handle
Message-Id: <20181025124249.0ba63f1041ed8836ff6e6190@linux-foundation.org>
In-Reply-To: <20181025112821.0924423fb9ecc7918896ec2b@gmail.com>
References: <20181025112821.0924423fb9ecc7918896ec2b@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Oleksiy.Avramchenko@sony.com, Guenter Roeck <linux@roeck-us.net>

On Thu, 25 Oct 2018 11:28:21 +0200 Vitaly Wool <vitalywool@gmail.com> wrote:

> Reclaim and free can race on an object (which is basically ok) but
> in order for reclaim to be able to  map "freed" object we need to
> encode object length in the handle. handle_to_chunks() is thus
> introduced to extract object length from a handle and use it during
> mapping of the last object we couldn't correctly map before.

What are the runtime effects of this change?

Thanks.
