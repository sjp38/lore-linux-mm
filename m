Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id AAED56B0038
	for <linux-mm@kvack.org>; Tue,  1 Dec 2015 04:44:45 -0500 (EST)
Received: by obdgf3 with SMTP id gf3so375462obd.3
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 01:44:45 -0800 (PST)
Received: from namei.org (tundra.namei.org. [65.99.196.166])
        by mx.google.com with ESMTPS id w188si4678437oib.17.2015.12.01.01.44.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Dec 2015 01:44:45 -0800 (PST)
Date: Tue, 1 Dec 2015 20:43:59 +1100 (AEDT)
From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 06/10] tmpfs: Use xattr handler infrastructure
In-Reply-To: <1448919823-27103-7-git-send-email-agruenba@redhat.com>
Message-ID: <alpine.LRH.2.20.1512012043380.15599@namei.org>
References: <1448919823-27103-1-git-send-email-agruenba@redhat.com> <1448919823-27103-7-git-send-email-agruenba@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

On Mon, 30 Nov 2015, Andreas Gruenbacher wrote:

> Use the VFS xattr handler infrastructure and get rid of similar code in
> the filesystem.  For implementing shmem_xattr_handler_set, we need a
> version of simple_xattr_set which removes the attribute when value is
> NULL.  Use this to implement kernfs_iop_removexattr as well.
> 
> Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: linux-mm@kvack.org


Reviewed-by: James Morris <james.l.morris@oracle.com>

-- 
James Morris
<jmorris@namei.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
