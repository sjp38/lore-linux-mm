From: Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Subject: Re: [PATCH 2/9] mm: implement new pkey_mprotect() system call
Date: Sat, 11 Jun 2016 11:47:44 +0200 (CEST)
Message-ID: <alpine.DEB.2.11.1606111147000.5839@nanos>
References: <20160609000117.71AC7623@viggo.jf.intel.com> <20160609000120.A3DD5140@viggo.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160609000120.A3DD5140-LXbPSdftPKxrdx17CPfAsdBPR1lH4CV8@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Dave Hansen <dave-gkUM19QKKo4@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, dave.hansen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org
List-Id: linux-mm.kvack.org

On Wed, 8 Jun 2016, Dave Hansen wrote:
> Proposed semantics:
> 1. protection key 0 is special and represents the default,
>    unassigned protection key.  It is always allocated.
> 2. mprotect() never affects a mapping's pkey_mprotect()-assigned
>    protection key. A protection key of 0 (even if set explicitly)
>    represents an unassigned protection key.
>    2a. mprotect(PROT_EXEC) on a mapping with an assigned protection
>        key may or may not result in a mapping with execute-only
>        properties.  pkey_mprotect() plus pkey_set() on all threads
>        should be used to _guarantee_ execute-only semantics.
> 3. mprotect(PROT_EXEC) may result in an "execute-only" mapping. The
>    kernel will internally attempt to allocate and dedicate a
>    protection key for the purpose of execute-only mappings.  This
>    may not be possible in cases where there are no free protection
>    keys available.

Shouldn't we just reserve a protection key for PROT_EXEC unconditionally?

Thanks,

	tglx
