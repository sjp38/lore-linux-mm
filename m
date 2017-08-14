Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 20A916B025F
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 09:42:47 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id a186so14018940wmh.9
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 06:42:47 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t9si5571099wrb.3.2017.08.14.06.42.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 14 Aug 2017 06:42:46 -0700 (PDT)
Date: Mon, 14 Aug 2017 15:42:43 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v6 04/15] mm: discard memblock data later
Message-ID: <20170814134243.GM19063@dhcp22.suse.cz>
References: <1502138329-123460-1-git-send-email-pasha.tatashin@oracle.com>
 <1502138329-123460-5-git-send-email-pasha.tatashin@oracle.com>
 <20170811093249.GE30811@dhcp22.suse.cz>
 <42a04441-47ad-2fa0-ca3c-784c717213f7@oracle.com>
 <20170814113445.GE19063@dhcp22.suse.cz>
 <aac7b5f1-5c5e-e716-af49-bc150449ddbc@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <aac7b5f1-5c5e-e716-af49-bc150449ddbc@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pasha Tatashin <pasha.tatashin@oracle.com>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, ard.biesheuvel@linaro.org, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, Mel Gorman <mgorman@suse.de>

On Mon 14-08-17 09:39:17, Pasha Tatashin wrote:
> >>#ifdef CONFIG_MEMBLOCK in page_alloc, or define memblock_discard() stubs in
> >>nobootmem headfile.
> >
> >This is the standard way to do this. And it is usually preferred to
> >proliferate ifdefs in the code.
> 
> Hi Michal,
> 
> As you suggested, I sent-out this patch separately. If you feel strongly,
> that this should be updated to have stubs for platforms that do not
> implement memblock, please send a reply to that e-mail, so those who do not
> follow this tread will see it. Otherwise, I can leave it as is, page_alloc
> file already has a number memblock related ifdefs all of which can be
> cleaned out once every platform implements it (is it even achievable?)

I do not think this needs a repost just for this. This was merely a
JFYI, in case you would need to repost for other reasons then just
update that as well. But nothing really earth shattering.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
