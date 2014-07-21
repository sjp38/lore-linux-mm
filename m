Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id 9035F6B0038
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 19:36:15 -0400 (EDT)
Received: by mail-qg0-f42.google.com with SMTP id j5so6374967qga.29
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 16:36:15 -0700 (PDT)
Received: from mail-qa0-x230.google.com (mail-qa0-x230.google.com [2607:f8b0:400d:c00::230])
        by mx.google.com with ESMTPS id h10si18849014qgd.93.2014.07.21.16.36.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 21 Jul 2014 16:36:14 -0700 (PDT)
Received: by mail-qa0-f48.google.com with SMTP id m5so5787449qaj.7
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 16:36:14 -0700 (PDT)
Date: Mon, 21 Jul 2014 19:36:14 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [PATCH v2 00/25] AMDKFD kernel driver
Message-ID: <20140721233613.GB6422@gmail.com>
References: <20140721155437.GA4519@gmail.com>
 <53CD5122.5040804@amd.com>
 <20140721181433.GA5196@gmail.com>
 <53CD5DBC.7010301@amd.com>
 <20140721185940.GA5278@gmail.com>
 <53CD68BF.4020308@amd.com>
 <20140721192837.GC5278@gmail.com>
 <53CD8C7D.9010106@amd.com>
 <20140721230535.GA6422@gmail.com>
 <D89D60253BB73A4E8C62F9FD18A939CA01062C69@storexdag02.amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <D89D60253BB73A4E8C62F9FD18A939CA01062C69@storexdag02.amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Bridgman, John" <John.Bridgman@amd.com>
Cc: "Gabbay, Oded" <Oded.Gabbay@amd.com>, "Lewycky, Andrew" <Andrew.Lewycky@amd.com>, "Pinchuk, Evgeny" <Evgeny.Pinchuk@amd.com>, "Daenzer, Michel" <Michel.Daenzer@amd.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, linux-mm <linux-mm@kvack.org>, "Skidanov, Alexey" <Alexey.Skidanov@amd.com>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Jul 21, 2014 at 11:29:23PM +0000, Bridgman, John wrote:
> >> >> So even if I really wanted to, and I may agree with you
> >> >> theoretically on that, I can't fulfill your desire to make the
> >> >> "kernel being able to preempt at any time and be able to decrease
> >> >> or increase user queue priority so overall kernel is in charge of
> >> >> resources management and it can handle rogue client in proper
> >> >> fashion". Not in KV, and I guess not in CZ as well.

                             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

> >
> >Also it is a worrisome prospect of seeing resource management completely
> >ignore for future AMD hardware. Kernel exist for a reason ! Kernel main
> >purpose is to provide resource management if AMD fails to understand that,
> >this is not looking good on long term and i expect none of the HSA
> >technology will get momentum and i would certainly advocate against any
> >use of it inside product i work on.
> 
> Hi Jerome;
> 
> I was following along until the above comment. It seems to be the exact opposite of what Oded has been saying, which is that future AMD hardware *does* have more capabilities for resource management and that we do have some capabilities today. Can you help me understand what the comment it was based on ?


Highlighted above.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
