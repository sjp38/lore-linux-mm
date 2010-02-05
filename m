Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 174006B0078
	for <linux-mm@kvack.org>; Fri,  5 Feb 2010 03:28:01 -0500 (EST)
Received: by fxm7 with SMTP id 7so3895915fxm.28
        for <linux-mm@kvack.org>; Fri, 05 Feb 2010 00:27:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <201002031039.710275915@firstfloor.org>
References: <201002031039.710275915@firstfloor.org>
Date: Fri, 5 Feb 2010 10:27:57 +0200
Message-ID: <84144f021002050027r3617d333scb875163e2e04c27@mail.gmail.com>
Subject: Re: [PATCH] [0/4] SLAB: Fix a couple of slab memory hotadd issues
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: submit@firstfloor.org, linux-kernel@vger.kernel.org, haicheng.li@intel.com, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Hi Andi,

On Wed, Feb 3, 2010 at 11:39 PM, Andi Kleen <andi@firstfloor.org> wrote:
> This fixes various problems in slab found during memory hotadd testing.
>
> All straight forward bug fixes, so could be still .33 candidates.

AFAICT, they aren't regression fixes so they should wait for .34, no?
The patches look good to me. Nick, Christoph, you might want to take a
peek at them before I shove them in linux-next.

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
