Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id F25D66B0006
	for <linux-mm@kvack.org>; Sun, 11 Mar 2018 15:49:40 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id d187so355143iog.6
        for <linux-mm@kvack.org>; Sun, 11 Mar 2018 12:49:40 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 185sor1720195itw.92.2018.03.11.12.49.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 11 Mar 2018 12:49:39 -0700 (PDT)
Date: Sun, 11 Mar 2018 12:49:37 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/slab.c: remove duplicated check of colour_next
In-Reply-To: <877eqilr71.fsf@gmail.com>
Message-ID: <alpine.DEB.2.20.1803111249180.155711@chino.kir.corp.google.com>
References: <877eqilr71.fsf@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Lakeev <sunnyddayss@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, 11 Mar 2018, Roman Lakeev wrote:

> Sorry for strange message in previous mail.
> 
> remove check that offset greater than cachep->colour
> bacause this is already checked in previous lines
> 
> Signed-off-by: Roman Lakeev <sunnyddayss@gmail.com>

Acked-by: David Rientjes <rientjes@google.com>
