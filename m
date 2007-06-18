Received: by py-out-1112.google.com with SMTP id a25so808579pyi
        for <linux-mm@kvack.org>; Mon, 18 Jun 2007 10:38:23 -0700 (PDT)
Message-ID: <6bffcb0e0706181038j107e2357o89c525261cf671a@mail.gmail.com>
Date: Mon, 18 Jun 2007 19:38:22 +0200
From: "Michal Piotrowski" <michal.k.k.piotrowski@gmail.com>
Subject: Re: [patch 00/26] Current slab allocator / SLUB patch queue
In-Reply-To: <Pine.LNX.4.64.0706180936280.4751@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070618095838.238615343@sgi.com>
	 <46767346.2040108@googlemail.com>
	 <Pine.LNX.4.64.0706180936280.4751@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, suresh.b.siddha@intel.com
List-ID: <linux-mm.kvack.org>

On 18/06/07, Christoph Lameter <clameter@sgi.com> wrote:
> On Mon, 18 Jun 2007, Michal Piotrowski wrote:
>
> > Result:
> >
> > [  212.247759] WARNING: at lib/vsprintf.c:280 vsnprintf()
> > [  212.253263]  [<c04052ad>] dump_trace+0x63/0x1eb
> > [  212.259042]  [<c040544f>] show_trace_log_lvl+0x1a/0x2f
> > [  212.266672]  [<c040608d>] show_trace+0x12/0x14
> > [  212.271622]  [<c04060a5>] dump_stack+0x16/0x18
> > [  212.276663]  [<c050d512>] vsnprintf+0x6b/0x48c
> > [  212.281325]  [<c050d9f0>] scnprintf+0x20/0x2d
> > [  212.286707]  [<c0508dbc>] bitmap_scnlistprintf+0xa8/0xec
> > [  212.292508]  [<c0480d40>] list_locations+0x24c/0x2a2
> > [  212.298241]  [<c0480dde>] alloc_calls_show+0x1f/0x26
> > [  212.303459]  [<c047e72e>] slab_attr_show+0x1c/0x20
> > [  212.309469]  [<c04c1cf9>] sysfs_read_file+0x94/0x105
> > [  212.315519]  [<c0485933>] vfs_read+0xcf/0x158
> > [  212.320215]  [<c0485d99>] sys_read+0x3d/0x72
> > [  212.327539]  [<c040420c>] syscall_call+0x7/0xb
> > [  212.332203]  [<b7f74410>] 0xb7f74410
> > [  212.336229]  =======================
> >
> > Unfortunately, I don't know which file was cat'ed
>
> The dump shows that it was alloc_calls. But the issue is not related to
> this patchset.
>
> Looks like we overflowed the buffer available for /sys output. The calls
> in list_location to format cpulist and node lists attempt to allow very
> long lists by trying to calculate how many bytes are remaining in the
> page. If we are beyond the space left over by them then we may pass a
> negative size to the scn_printf functions.
>
> So we need to check first if there are enough bytes remaining before
> doing the calculation of how many remaining bytes can be used to
> format these lists.
>
> Does this patch fix the issue?
>

Unfortunately no.

AFAIR I didn't see it in 2.6.22-rc4-mm2

Regards,
Michal

-- 
LOG
http://www.stardust.webpages.pl/log/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
