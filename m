Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 70B036B0253
	for <linux-mm@kvack.org>; Fri, 21 Aug 2015 05:36:47 -0400 (EDT)
Received: by pdrh1 with SMTP id h1so25264965pdr.0
        for <linux-mm@kvack.org>; Fri, 21 Aug 2015 02:36:47 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id p10si12013831pds.132.2015.08.21.02.36.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Aug 2015 02:36:46 -0700 (PDT)
Date: Fri, 21 Aug 2015 12:36:31 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH v3 03/20] list_lru: add list_lru_rotate
Message-ID: <20150821093631.GK2797@esperanza>
References: <1440069440-27454-1-git-send-email-jeff.layton@primarydata.com>
 <1440069440-27454-4-git-send-email-jeff.layton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1440069440-27454-4-git-send-email-jeff.layton@primarydata.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org, hch@lst.de, kinglongmee@gmail.com, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Thu, Aug 20, 2015 at 07:17:03AM -0400, Jeff Layton wrote:
> Add a function that can move an entry to the MRU end of the list.
> 
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Vladimir Davydov <vdavydov@parallels.com>
> Cc: linux-mm@kvack.org
> Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>

Reviewed-by: Vladimir Davydov <vdavydov@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
