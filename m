Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 77F616B0038
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 00:07:55 -0500 (EST)
Received: by pdbfl12 with SMTP id fl12so23182352pdb.5
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 21:07:55 -0800 (PST)
Received: from mail-pd0-x235.google.com (mail-pd0-x235.google.com. [2607:f8b0:400e:c02::235])
        by mx.google.com with ESMTPS id u4si3411553pdp.211.2015.03.03.21.07.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Mar 2015 21:07:54 -0800 (PST)
Received: by pdjy10 with SMTP id y10so54397774pdj.6
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 21:07:54 -0800 (PST)
Date: Wed, 4 Mar 2015 14:07:43 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2 1/7] zsmalloc: decouple handle and object
Message-ID: <20150304050742.GA5418@blaptop>
References: <1425445292-29061-1-git-send-email-minchan@kernel.org>
 <1425445292-29061-2-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1425445292-29061-2-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Juneho Choi <juno.choi@lge.com>, Gunho Lee <gunho.lee@lge.com>, Luigi Semenzato <semenzato@google.com>, Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjennings@variantweb.net>, Nitin Gupta <ngupta@vflare.org>, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, opensource.ganesh@gmail.com

Oops. I sent old version which had a bug Ganesh pointed out.
Sorry for that.
Please review this instead.
