Received: by ug-out-1314.google.com with SMTP id s2so70651uge
        for <linux-mm@kvack.org>; Thu, 22 Feb 2007 02:49:11 -0800 (PST)
Message-ID: <84144f020702220249k37306252q627bf3ceb28e8b5d@mail.gmail.com>
Date: Thu, 22 Feb 2007 12:49:11 +0200
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: SLUB: The unqueued Slab allocator
In-Reply-To: <Pine.LNX.4.64.0702212250271.30485@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <Pine.LNX.4.64.0702212250271.30485@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Christoph,

On 2/22/07, Christoph Lameter <clameter@sgi.com> wrote:
> This is a new slab allocator which was motivated by the complexity of the
> existing code in mm/slab.c. It attempts to address a variety of concerns
> with the existing implementation.

So do you want to add a new allocator or replace slab?

On 2/22/07, Christoph Lameter <clameter@sgi.com> wrote:
> B. Storage overhead of object queues

Does this make sense for non-NUMA too? If not, can we disable the
queues for NUMA in current slab?

On 2/22/07, Christoph Lameter <clameter@sgi.com> wrote:
> C. SLAB metadata overhead

Can be done for the current slab code too, no?

                                                 Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
