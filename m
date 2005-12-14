Received: by nproxy.gmail.com with SMTP id l23so17903nfc
        for <linux-mm@kvack.org>; Wed, 14 Dec 2005 00:37:40 -0800 (PST)
Message-ID: <84144f020512140037k5d687c66x35e3e29519764fb7@mail.gmail.com>
Date: Wed, 14 Dec 2005 10:37:39 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: Re: [RFC][PATCH 4/6] Slab Prep: slab_destruct()
In-Reply-To: <439FD08E.3020401@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <439FCECA.3060909@us.ibm.com> <439FD08E.3020401@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Dobson <colpatch@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, andrea@suse.de, Sridhar Samudrala <sri@us.ibm.com>, pavel@suse.cz, Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 12/14/05, Matthew Dobson <colpatch@us.ibm.com> wrote:
> Create a helper function for slab_destroy() called slab_destruct().  Remove
> some ifdefs inside functions and generally make the slab destroying code
> more readable prior to slab support for the Critical Page Pool.

Looks good. How about calling it slab_destroy_objs instead?

                          Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
