Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 65E8C6B004D
	for <linux-mm@kvack.org>; Mon, 14 Sep 2009 02:27:29 -0400 (EDT)
Received: by bwz24 with SMTP id 24so1911983bwz.38
        for <linux-mm@kvack.org>; Sun, 13 Sep 2009 23:27:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4AADBB77.5050803@redhat.com>
References: <1252866835.13780.37.camel@dhcp231-106.rdu.redhat.com>
	 <1252883493.16335.8.camel@dhcp231-106.rdu.redhat.com>
	 <4AADBB77.5050803@redhat.com>
Date: Mon, 14 Sep 2009 09:27:36 +0300
Message-ID: <84144f020909132327u701bde60ibc558eb91ca2b391@mail.gmail.com>
Subject: Re: [GIT BISECT] BUG kmalloc-8192: Object already free from
	kmem_cache_destroy
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Danny Feng <dfeng@redhat.com>
Cc: Eric Paris <eparis@redhat.com>, cl@linux-foundation.org, mingo@elte.hu, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 14, 2009 at 6:41 AM, Danny Feng <dfeng@redhat.com> wrote:
> That's my fault... Please drop this patch, I didn't notice the free action
> in kobject release phase.. Thanks for point it out.

Dropped, thanks Eric!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
