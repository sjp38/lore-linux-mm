Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 8FA9B6B0075
	for <linux-mm@kvack.org>; Fri,  6 Jul 2012 04:23:06 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so17184260pbb.14
        for <linux-mm@kvack.org>; Fri, 06 Jul 2012 01:23:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1341553919-4442-1-git-send-email-shangw@linux.vnet.ibm.com>
References: <1341553919-4442-1-git-send-email-shangw@linux.vnet.ibm.com>
Date: Fri, 6 Jul 2012 16:23:05 +0800
Message-ID: <CAM_iQpXxqQkn_SgSf-5krmm9tCHEk21h9S3z8RhwR4XAeh8dFQ@mail.gmail.com>
Subject: Re: [PATCH v2] mm/buddy: more comments for show_free_areas()
From: Cong Wang <xiyou.wangcong@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Shan <shangw@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org

On Fri, Jul 6, 2012 at 1:51 PM, Gavin Shan <shangw@linux.vnet.ibm.com> wrote:
> The initial idea comes from Cong Wang. We're running out of memory
> while calling function show_free_areas(). So it would be unsafe
> to allocate more memory from either stack or heap. The patche adds
> more comments to address that.
>

Looks good to me,

Reviewed-by: WANG Cong <xiyou.wangcong@gmail.com>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
