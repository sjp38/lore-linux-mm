Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 379A66B0260
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 13:31:52 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id 207so341615iti.5
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 10:31:52 -0800 (PST)
Received: from resqmta-po-07v.sys.comcast.net (resqmta-po-07v.sys.comcast.net. [2001:558:fe16:19:96:114:154:166])
        by mx.google.com with ESMTPS id j14si13452116itc.77.2018.01.10.10.31.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jan 2018 10:31:51 -0800 (PST)
Date: Wed, 10 Jan 2018 12:31:47 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 05/36] usercopy: WARN() on slab cache usercopy region
 violations
In-Reply-To: <1515531365-37423-6-git-send-email-keescook@chromium.org>
Message-ID: <alpine.DEB.2.20.1801101229380.7926@nuc-kabylake>
References: <1515531365-37423-1-git-send-email-keescook@chromium.org> <1515531365-37423-6-git-send-email-keescook@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: linux-kernel@vger.kernel.org, David Windsor <dave@nullcore.net>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Laura Abbott <labbott@redhat.com>, Ingo Molnar <mingo@kernel.org>, Mark Rutland <mark.rutland@arm.com>, linux-mm@kvack.org, linux-xfs@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@kernel.org>, Christoph Hellwig <hch@infradead.org>, "David S. Miller" <davem@davemloft.net>, "Martin K. Petersen" <martin.petersen@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Christoffer Dall <christoffer.dall@linaro.org>, Dave Kleikamp <dave.kleikamp@oracle.com>, Jan Kara <jack@suse.cz>, Luis de Bethencourt <luisbg@kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, Rik van Riel <riel@redhat.com>, Matthew Garrett <mjg59@google.com>, linux-fsdevel@vger.kernel.org, linux-arch@vger.kernel.org, netdev@vger.kernel.org, kernel-hardening@lists.openwall.com

On Tue, 9 Jan 2018, Kees Cook wrote:

> @@ -3823,11 +3825,9 @@ int __check_heap_object(const void *ptr, unsigned long n, struct page *page,

Could we do the check in mm_slab_common.c for all allocators and just have
a small function in each allocators that give you the metadata needed for
the object?

> + * carefully audit the whitelist range).
> + */
>  int report_usercopy(const char *name, const char *detail, bool to_user,
>  		    unsigned long offset, unsigned long len)
>  {

Should this not be added earlier?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
