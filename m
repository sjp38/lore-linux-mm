Received: by py-out-1112.google.com with SMTP id f47so1764364pye.20
        for <linux-mm@kvack.org>; Mon, 18 Feb 2008 09:37:54 -0800 (PST)
Message-ID: <84144f020802180937p6bea0a25t93b8f9c7202b06e2@mail.gmail.com>
Date: Mon, 18 Feb 2008 19:37:53 +0200
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: Slab initialisation problems on MN10300
In-Reply-To: <84144f020802180918h6fb4d52fw4c592407a16b19c0@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <16085.1203350863@redhat.com>
	 <84144f020802180918h6fb4d52fw4c592407a16b19c0@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Howells <dhowells@redhat.com>
Cc: clameter@sgi.com, mpm@selenic.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Feb 18, 2008 7:18 PM, Pekka Enberg <penberg@cs.helsinki.fi> wrote:
> And if this broke recently, you might want to try and see if commit
> 556a169dab38b5100df6f4a45b655dddd3db94c1 ("slab: fix bootstrap on
> memoryless node") is at fault here by reverting it.

Hmm, I double-checked the patch and it probably isn't the cause here.
It's just that we haven't changed SLAB bootstrap all that much except
for this patch. One thing that I thought of was ARCH_KMALLOC_MINALIGN
which is set to some fairly big values on some MIPS architectures
(MN10300 is one, right?) but reading the code I wasn't able to see
what could go wrong with that either...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
