Received: by rv-out-0708.google.com with SMTP id f25so695053rvb.26
        for <linux-mm@kvack.org>; Wed, 07 May 2008 22:27:47 -0700 (PDT)
Message-ID: <84144f020805072227i3382465eleccded79d9fcf532@mail.gmail.com>
Date: Thu, 8 May 2008 08:27:47 +0300
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [PATCH 08 of 11] anon-vma-rwsem
In-Reply-To: <20080508052019.GA8276@duo.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080507153103.237ea5b6.akpm@linux-foundation.org>
	 <20080507155914.d7790069.akpm@linux-foundation.org>
	 <20080507233953.GM8276@duo.random>
	 <alpine.LFD.1.10.0805071757520.3024@woody.linux-foundation.org>
	 <Pine.LNX.4.64.0805071809170.14935@schroedinger.engr.sgi.com>
	 <20080508025652.GW8276@duo.random>
	 <Pine.LNX.4.64.0805072009230.15543@schroedinger.engr.sgi.com>
	 <20080508034133.GY8276@duo.random>
	 <alpine.LFD.1.10.0805072109430.3024@woody.linux-foundation.org>
	 <20080508052019.GA8276@duo.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, steiner@sgi.com, holt@sgi.com, npiggin@suse.de, a.p.zijlstra@chello.nl, kvm-devel@lists.sourceforge.net, kanojsarcar@yahoo.com, rdreier@cisco.com, swise@opengridcomputing.com, linux-kernel@vger.kernel.org, avi@qumranet.com, linux-mm@kvack.org, general@lists.openfabrics.org, hugh@veritas.com, rusty@rustcorp.com.au, aliguori@us.ibm.com, chrisw@redhat.com, marcelo@kvack.org, dada1@cosmosbay.com, paulmck@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Thu, May 8, 2008 at 8:20 AM, Andrea Arcangeli <andrea@qumranet.com> wrote:
>  Actually I looked both at the struct and at the slab alignment just in
>  case it was changed recently. Now after reading your mail I also
>  compiled it just in case.
>
>  @@ -27,6 +27,7 @@ struct anon_vma {
>   struct anon_vma {
>
>         spinlock_t lock;        /* Serialize access to vma list */
>
>         struct list_head head;  /* List of private "related" vmas */
>  +       int flag:1;
>   };

You might want to read carefully what Linus wrote:

> The one that already has a 4 byte padding thing on x86-64 just after the
> spinlock? And that on 32-bit x86 (with less than 256 CPU's) would have two
> bytes of padding if we didn't just make the spinlock type unconditionally
> 32 bits rather than the 16 bits we actually _use_?

So you need to add the flag _after_ ->lock and _before_ ->head....

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
