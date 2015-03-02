Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f174.google.com (mail-qc0-f174.google.com [209.85.216.174])
	by kanga.kvack.org (Postfix) with ESMTP id 1D9106B0038
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 18:45:34 -0500 (EST)
Received: by qcxm20 with SMTP id m20so27654931qcx.0
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 15:45:33 -0800 (PST)
Received: from mail-qc0-x22b.google.com (mail-qc0-x22b.google.com. [2607:f8b0:400d:c01::22b])
        by mx.google.com with ESMTPS id i204si13037937qhc.40.2015.03.02.15.45.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Mar 2015 15:45:33 -0800 (PST)
Received: by qcvp6 with SMTP id p6so27675441qcv.12
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 15:45:33 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1425113842-11694-1-git-send-email-sasha.levin@oracle.com>
References: <1425113842-11694-1-git-send-email-sasha.levin@oracle.com>
From: Gregory Fong <gregory.0xf0@gmail.com>
Date: Mon, 2 Mar 2015 15:45:02 -0800
Message-ID: <CADtm3G4ewz6sznNh6u0G+7iNhr9jpmx=AJH1qZ3kfPhw2fqFyA@mail.gmail.com>
Subject: Re: [PATCH] mm: cma: constify and use correct signness in mm/cma.c
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org

On Sat, Feb 28, 2015 at 12:57 AM, Sasha Levin <sasha.levin@oracle.com> wrote:
> Constify function parameters and use correct signness where needed.
>
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>

Acked-by: Gregory Fong <gregory.0xf0@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
