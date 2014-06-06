Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id D60B06B0035
	for <linux-mm@kvack.org>; Fri,  6 Jun 2014 06:24:27 -0400 (EDT)
Received: by mail-qg0-f43.google.com with SMTP id 63so3942199qgz.16
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 03:24:27 -0700 (PDT)
Received: from mail-qg0-x22e.google.com (mail-qg0-x22e.google.com [2607:f8b0:400d:c04::22e])
        by mx.google.com with ESMTPS id d4si12420504qai.92.2014.06.06.03.24.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 06 Jun 2014 03:24:27 -0700 (PDT)
Received: by mail-qg0-f46.google.com with SMTP id q108so3852301qgd.19
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 03:24:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140606095836.65149718001@webmail.sinamail.sina.com.cn>
References: <20140606095836.65149718001@webmail.sinamail.sina.com.cn>
Date: Fri, 6 Jun 2014 05:24:27 -0500
Message-ID: <CAMP44s2uzcB78s=y9r0pyk5m8ezaaNtAYKiRAw6O+_ZTfzeF2A@mail.gmail.com>
Subject: Re: Interactivity regression since v3.11 in mm/vmscan.c
From: Felipe Contreras <felipe.contreras@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhdxzx@sina.com
Cc: Michal Hocko <mhocko@suse.cz>, linux-kernel <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, dhillf <dhillf@gmail.com>

On Fri, Jun 6, 2014 at 4:58 AM,  <zhdxzx@sina.com> wrote:

> Alternatively can we try wait_iff_congested(zone, BLK_RW_ASYNC, HZ/10) ?

I see the same problem with that code.

-- 
Felipe Contreras

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
