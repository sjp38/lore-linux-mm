Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id A68F56B0038
	for <linux-mm@kvack.org>; Thu,  2 Apr 2015 11:03:05 -0400 (EDT)
Received: by wibgn9 with SMTP id gn9so108927470wib.1
        for <linux-mm@kvack.org>; Thu, 02 Apr 2015 08:03:05 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id md11si9914152wic.55.2015.04.02.08.03.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 02 Apr 2015 08:03:03 -0700 (PDT)
Date: Thu, 2 Apr 2015 17:02:58 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 0/9 v2] Helper to abstract vma handling in media layer
Message-ID: <20150402150258.GA31277@quack.suse.cz>
References: <1426593399-6549-1-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1426593399-6549-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-media@vger.kernel.org
Cc: Hans Verkuil <hans.verkuil@cisco.com>, Mauro Carvalho Chehab <mchehab@osg.samsung.com>, linux-mm@kvack.org, dri-devel@lists.freedesktop.org, David Airlie <airlied@linux.ie>, Jan Kara <jack@suse.cz>

  Hello,

On Tue 17-03-15 12:56:30, Jan Kara wrote:
>   After a long pause I'm sending second version of my patch series to abstract
> vma handling from the various media drivers. After this patch set drivers have
> to know much less details about vmas, their types, and locking. My motivation
> for the series is that I want to change get_user_pages() locking and I want to
> handle subtle locking details in as few places as possible.
> 
> The core of the series is the new helper get_vaddr_pfns() which is given a
> virtual address and it fills in PFNs into provided array. If PFNs correspond to
> normal pages it also grabs references to these pages. The difference from
> get_user_pages() is that this function can also deal with pfnmap, mixed, and io
> mappings which is what the media drivers need.
> 
> I have tested the patches with vivid driver so at least vb2 code got some
> exposure. Conversion of other drivers was just compile-tested so I'd like to
> ask respective maintainers if they could have a look.  Also I'd like to ask mm
> folks to check patch 2/9 implementing the helper. Thanks!
  Ping? Any reactions?

								Honza

-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
