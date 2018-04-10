Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6B3576B0028
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 16:23:57 -0400 (EDT)
Received: by mail-yb0-f198.google.com with SMTP id t11-v6so6472221ybi.3
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 13:23:57 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s63-v6sor50472ybf.5.2018.04.10.13.23.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 10 Apr 2018 13:23:56 -0700 (PDT)
Date: Tue, 10 Apr 2018 13:23:53 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC] mm, slab: reschedule cache_reap() on the same CPU
Message-ID: <20180410202353.GB793541@devbig577.frc2.facebook.com>
References: <20180410081531.18053-1-vbabka@suse.cz>
 <alpine.DEB.2.20.1804100907160.27333@nuc-kabylake>
 <983c61d1-1444-db1f-65c1-3b519ac4d57b@suse.cz>
 <20180410195247.GQ3126663@devbig577.frc2.facebook.com>
 <d4983f13-2c02-6082-f980-a6623ab363e6@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d4983f13-2c02-6082-f980-a6623ab363e6@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Christopher Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Lai Jiangshan <jiangshanlai@gmail.com>, John Stultz <john.stultz@linaro.org>, Thomas Gleixner <tglx@linutronix.de>, Stephen Boyd <sboyd@kernel.org>

Hello,

On Tue, Apr 10, 2018 at 10:13:33PM +0200, Vlastimil Babka wrote:
> > For percpu work items, they'll keep executing on the same cpu it
> > started on unless the cpu goes down while executing.
> 
> Right, but before this patch, with just schedule_delayed_work() i.e.
> non-percpu? If such work can migrate in the middle, the slab bug is
> potentially much more serious.

That's still per-cpu.  The only time the local binding breaks is when
the kernel is explicitly told to do so through explicit unbound_mask
or force_rr debug option.

Thanks.

-- 
tejun
