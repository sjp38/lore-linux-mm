Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 896A36B0071
	for <linux-mm@kvack.org>; Wed,  9 Jun 2010 23:29:54 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <c773d65b-e107-428c-ba6f-04d4ca9f8361@default>
Date: Wed, 9 Jun 2010 20:28:21 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH V2 2/7] Cleancache (was Transcendent Memory): core files
References: <20100528173550.GA12219@ca-server1.us.oracle.com
 4C1042E0.8080403@vflare.org>
In-Reply-To: <4C1042E0.8080403@vflare.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: ngupta@vflare.org
Cc: chris.mason@oracle.com, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, adilger@sun.com, tytso@mit.edu, mfasheh@suse.com, joel.becker@oracle.com, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, jeremy@goop.org, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@suse.de, dave.mccracken@oracle.com, riel@redhat.com, avi@redhat.com, konrad.wilk@oracle.com
List-ID: <linux-mm.kvack.org>

> I just finished a rough (but working) implementation of in-kernel
> page cache compression backend (called zcache). During this work,
> I found some issues with cleancache, mostly related to (lack of)
> comments/documentation:

Great to hear!  And excellent feedback on the missing
documentation... I am working on this right now so your
feedback is very timely.

(documentation and funcition return values comments deleted
as I will fix all of them)

> > +
> > +static inline int cleancache_init_fs(size_t pagesize)
> > +
>=20
>  - It seems that returning pool_id of 0 is considered as error
> condition (as it appears from deactivate_locked_super() changes).
> This seems weird; I think only negative pool_id should considered
> as error. Anyway, please add function comments for these.

Hmmm... this is a bug.  0 is a valid pool_id.  I'll fix it
for the next rev.

> Page cache compression was a long-pending project. I'm glad its
> coming into shape with the help of cleancache :)

Thanks!
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
