Received: by nproxy.gmail.com with SMTP id l23so16977nfc
        for <linux-mm@kvack.org>; Wed, 14 Dec 2005 00:19:33 -0800 (PST)
Message-ID: <84144f020512140019h1390c9eayf8b4b0dd03d8be1c@mail.gmail.com>
Date: Wed, 14 Dec 2005 10:19:33 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: Re: [RFC][PATCH 3/6] Slab Prep: get/return_object
In-Reply-To: <439FD031.1040608@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <439FCECA.3060909@us.ibm.com> <439FD031.1040608@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Dobson <colpatch@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, andrea@suse.de, Sridhar Samudrala <sri@us.ibm.com>, pavel@suse.cz, Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Matt,

On 12/14/05, Matthew Dobson <colpatch@us.ibm.com> wrote:
> Create 2 helper functions in mm/slab.c: get_object() and return_object().
> These functions reduce some existing duplicated code in the slab allocator
> and will be used when adding Critical Page Pool support to the slab allocator.

May I suggest different naming, slab_get_obj and slab_put_obj ?

                                            Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
