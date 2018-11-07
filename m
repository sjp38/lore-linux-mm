Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id D53776B0574
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 17:55:11 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id b88-v6so16649102pfj.4
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 14:55:11 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a72sor2631784pge.21.2018.11.07.14.55.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Nov 2018 14:55:10 -0800 (PST)
Date: Wed, 7 Nov 2018 14:55:07 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm, slab: remove unnecessary unlikely()
In-Reply-To: <20181104125028.3572-1-tiny.windzz@gmail.com>
Message-ID: <alpine.DEB.2.21.1811071454580.230996@chino.kir.corp.google.com>
References: <20181104125028.3572-1-tiny.windzz@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yangtao Li <tiny.windzz@gmail.com>
Cc: cl@linux.com, penberg@kernel.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, 4 Nov 2018, Yangtao Li wrote:

> WARN_ON() already contains an unlikely(), so it's not necessary to use
> unlikely.
> 
> Signed-off-by: Yangtao Li <tiny.windzz@gmail.com>

Acked-by: David Rientjes <rientjes@google.com>
