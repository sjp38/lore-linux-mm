Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id C1A336B0292
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 12:40:01 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id v76so8487218qka.5
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 09:40:01 -0700 (PDT)
Received: from mail-qk0-x230.google.com (mail-qk0-x230.google.com. [2607:f8b0:400d:c09::230])
        by mx.google.com with ESMTPS id i40si12000530qkh.265.2017.07.25.09.40.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jul 2017 09:40:01 -0700 (PDT)
Received: by mail-qk0-x230.google.com with SMTP id d145so65458502qkc.2
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 09:40:00 -0700 (PDT)
Date: Tue, 25 Jul 2017 12:39:57 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: pcpu allocator on large NUMA machines
Message-ID: <20170725163957.GA3216015@devbig577.frc2.facebook.com>
References: <20170724134240.GL25221@dhcp22.suse.cz>
 <20170724135714.GA3240919@devbig577.frc2.facebook.com>
 <20170724142826.GN25221@dhcp22.suse.cz>
 <877eyxz4r8.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <877eyxz4r8.fsf@concordia.ellerman.id.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Michal Hocko <mhocko@kernel.org>, Jiri Kosina <jkosina@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hello, Michael.

On Tue, Jul 25, 2017 at 11:26:03AM +1000, Michael Ellerman wrote:
> I don't think we want to stop using embed first chunk unless we have to.
> 
> We have code that accesses percpu variables in real mode (with the MMU
> off), and that wouldn't work easily if the first chunk wasn't in the
> linear mapping. So it's not just an optimisation for us.
> 
> We can fairly easily make the vmalloc space 56T, and I'm working on a
> patch to make it ~500T on newer machines.

Yeah, the only constraint is the size of vmalloc area in relation to
the maximum spread across NUMA regions.  If the vmalloc space can be
made bigger, that'd be the best option.  As the area percpu allocator
actually uses is very small comparatively, it doesn't have to be a lot
larger either.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
