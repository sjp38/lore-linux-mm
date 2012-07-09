Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 3147E6B0072
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 17:21:38 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rp2so24005137pbb.14
        for <linux-mm@kvack.org>; Mon, 09 Jul 2012 14:21:37 -0700 (PDT)
Date: Mon, 9 Jul 2012 14:21:35 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] mm/buddy: more comments for show_free_areas()
In-Reply-To: <CAM_iQpXxqQkn_SgSf-5krmm9tCHEk21h9S3z8RhwR4XAeh8dFQ@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1207091421200.23926@chino.kir.corp.google.com>
References: <1341553919-4442-1-git-send-email-shangw@linux.vnet.ibm.com> <CAM_iQpXxqQkn_SgSf-5krmm9tCHEk21h9S3z8RhwR4XAeh8dFQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Cc: Gavin Shan <shangw@linux.vnet.ibm.com>, linux-mm@kvack.org, akpm@linux-foundation.org

On Fri, 6 Jul 2012, Cong Wang wrote:

> > The initial idea comes from Cong Wang. We're running out of memory
> > while calling function show_free_areas(). So it would be unsafe
> > to allocate more memory from either stack or heap. The patche adds
> > more comments to address that.
> >
> 
> Looks good to me,
> 
> Reviewed-by: WANG Cong <xiyou.wangcong@gmail.com>
> 

Nack, please see my response to the first version.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
