Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f47.google.com (mail-qa0-f47.google.com [209.85.216.47])
	by kanga.kvack.org (Postfix) with ESMTP id C070F6B0039
	for <linux-mm@kvack.org>; Tue, 22 Jul 2014 18:58:56 -0400 (EDT)
Received: by mail-qa0-f47.google.com with SMTP id i13so400946qae.20
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 15:58:56 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d4si937055qac.44.2014.07.22.15.58.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Jul 2014 15:58:56 -0700 (PDT)
Date: Tue, 22 Jul 2014 18:58:41 -0400
From: Mike Snitzer <snitzer@redhat.com>
Subject: [git pull] stable mm/slab_common.c fix for 3.16-rc7
Message-ID: <20140722225841.GA5379@redhat.com>
References: <alpine.LRH.2.02.1403041711300.29476@file01.intranet.prod.int.rdu2.redhat.com>
 <20140325170324.GC580@redhat.com>
 <alpine.DEB.2.10.1403251306260.26471@nuc>
 <20140523201632.GA16013@redhat.com>
 <537FBD6F.1070009@iki.fi>
 <20140722221421.GA11318@redhat.com>
 <alpine.DEB.2.02.1407221539020.5814@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1407221539020.5814@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@iki.fi>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, dm-devel@redhat.com, linux-kernel@vger.kernel.org, "Alasdair G. Kergon" <agk@redhat.com>, Mikulas Patocka <mpatocka@redhat.com>, Zdenek Kabelac <zkabelac@redhat.com>

Hi Linus,

Not sure you'll be OK with what I've done or not but I pulled in a
1-liner "slab/urgent" fix that Pekka staged a couple months ago.  I've
made it available through a signed tag in the linux-dm.git tree.  My
reasoning on why this is OK is it regularly impacts DM and Pekka already
Signed-off on it (as did other mm developers).  I'm pretty sure Pekka
just forgot to follow through preparing a pull request for 3.15.

If you'd rather take this direct from Pekka (or wait for Andrew to pick
up the same patch which David just sent him) that is fine by me, I just
want the issue fixed.

The following changes since commit 048e5a07f282c57815b3901d4a68a77fa131ce0a:

  dm cache metadata: do not allow the data block size to change (2014-07-15 14:07:50 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/device-mapper/linux-dm.git tags/urgent-slab-fix

for you to fetch changes up to 45ccaf4764278f6544db412d38a1bae056ee3acc:

  Merge branch 'slab/urgent' of git://git.kernel.org/pub/scm/linux/kernel/git/penberg/linux into for-3.16-rcX (2014-07-22 18:38:27 -0400)

Please pull, thanks.
Mike

----------------------------------------------------------------

This fixes the broken duplicate slab name check in
kmem_cache_sanity_check() that has been repeatedly reported (as recently
as today against Fedora rawhide).  Pekka seemed to have it staged for a
late 3.15-rc in his 'slab/urgent' branch but never sent a pull request,
see: https://lkml.org/lkml/2014/5/23/648

----------------------------------------------------------------
Mike Snitzer (1):
      Merge branch 'slab/urgent' of git://git.kernel.org/.../penberg/linux into for-3.16-rcX

Mikulas Patocka (1):
      slab_common: fix the check for duplicate slab names

 mm/slab_common.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
