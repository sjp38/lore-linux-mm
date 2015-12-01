Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f42.google.com (mail-oi0-f42.google.com [209.85.218.42])
	by kanga.kvack.org (Postfix) with ESMTP id 0FFE96B0038
	for <linux-mm@kvack.org>; Tue,  1 Dec 2015 04:45:50 -0500 (EST)
Received: by oies6 with SMTP id s6so343505oie.1
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 01:45:49 -0800 (PST)
Received: from namei.org (tundra.namei.org. [65.99.196.166])
        by mx.google.com with ESMTPS id l5si21347673obu.32.2015.12.01.01.45.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Dec 2015 01:45:49 -0800 (PST)
Date: Tue, 1 Dec 2015 20:45:05 +1100 (AEDT)
From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 07/10] tmpfs: listxattr should include POSIX ACL xattrs
In-Reply-To: <1448919823-27103-8-git-send-email-agruenba@redhat.com>
Message-ID: <alpine.LRH.2.20.1512012044420.15599@namei.org>
References: <1448919823-27103-1-git-send-email-agruenba@redhat.com> <1448919823-27103-8-git-send-email-agruenba@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

On Mon, 30 Nov 2015, Andreas Gruenbacher wrote:

> When a file on tmpfs has an ACL or a Default ACL, listxattr should include the
> corresponding xattr name.
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
