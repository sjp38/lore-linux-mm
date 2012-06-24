Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 761716B02E5
	for <linux-mm@kvack.org>; Sun, 24 Jun 2012 15:18:21 -0400 (EDT)
Received: by yhjj52 with SMTP id j52so3187723yhj.8
        for <linux-mm@kvack.org>; Sun, 24 Jun 2012 12:18:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1340466776-4976-5-git-send-email-shangw@linux.vnet.ibm.com>
References: <1340466776-4976-1-git-send-email-shangw@linux.vnet.ibm.com> <1340466776-4976-5-git-send-email-shangw@linux.vnet.ibm.com>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Sun, 24 Jun 2012 15:18:00 -0400
Message-ID: <CAHGf_=o7CGkJevngH0UGn-FWaEEO1zTkFD+DjWDA_NDeHcVnnw@mail.gmail.com>
Subject: Re: [PATCH 5/5] mm/sparse: return 0 if root mem_section exists
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Shan <shangw@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, akpm@linux-foundation.org

On Sat, Jun 23, 2012 at 11:52 AM, Gavin Shan <shangw@linux.vnet.ibm.com> wrote:
> Function sparse_index_init() is used to setup memory section descriptors
> dynamically. zero should be returned while mem_section[root] already has
> been allocated.

Why?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
