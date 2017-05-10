Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6FF676B03A4
	for <linux-mm@kvack.org>; Wed, 10 May 2017 12:18:58 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id 25so78979qtx.11
        for <linux-mm@kvack.org>; Wed, 10 May 2017 09:18:58 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q34si3501639qte.281.2017.05.10.09.18.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 May 2017 09:18:57 -0700 (PDT)
Date: Wed, 10 May 2017 12:18:51 -0400 (EDT)
From: Bob Peterson <rpeterso@redhat.com>
Message-ID: <1840580824.6421109.1494433131277.JavaMail.zimbra@redhat.com>
In-Reply-To: <20170509154930.29524-24-jlayton@redhat.com>
References: <20170509154930.29524-1-jlayton@redhat.com> <20170509154930.29524-24-jlayton@redhat.com>
Subject: Re: [PATCH v4 23/27] gfs2: clean up some filemap_* calls
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net, linux-xfs@vger.kernel.org, cluster-devel@redhat.com, linux-f2fs-devel@lists.sourceforge.net, v9fs-developer@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-block@vger.kernel.org, dhowells@redhat.com, akpm@linux-foundation.org, hch@infradead.org, ross zwisler <ross.zwisler@linux.intel.com>, mawilcox@microsoft.com, jack@suse.com, viro@zeniv.linux.org.uk, corbet@lwn.net, neilb@suse.de, clm@fb.com, tytso@mit.edu, axboe@kernel.dk, josef@toxicpanda.com, hubcap@omnibond.com, bo li liu <bo.li.liu@oracle.com>

----- Original Message -----
| In some places, it's trying to reset the mapping error after calling
| filemap_fdatawait. That's no longer required. Also, turn several
| filemap_fdatawrite+filemap_fdatawait calls into filemap_write_and_wait.
| That will at least return writeback errors that occur during the write
| phase.
| 
| Signed-off-by: Jeff Layton <jlayton@redhat.com>
| ---

Hi Jeff,

This version looks better. ACK.

Regards,

Bob Peterson
Red Hat File Systems

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
