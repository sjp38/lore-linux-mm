Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 41FE16B0037
	for <linux-mm@kvack.org>; Wed,  2 Jul 2014 23:42:56 -0400 (EDT)
Received: by mail-wg0-f42.google.com with SMTP id z12so11905693wgg.13
        for <linux-mm@kvack.org>; Wed, 02 Jul 2014 20:42:55 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t20si22342463wiv.102.2014.07.02.20.42.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Jul 2014 20:42:55 -0700 (PDT)
Date: Wed, 2 Jul 2014 23:39:01 -0400
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: Re: [PATCH] x86: numa: setup_node_data(): drop dead code and rename
 function
Message-ID: <20140702233901.5d48f0ea@redhat.com>
In-Reply-To: <alpine.DEB.2.02.1407021615550.5931@chino.kir.corp.google.com>
References: <20140619222019.3db6ad7e@redhat.com>
	<alpine.DEB.2.02.1406301639390.1327@chino.kir.corp.google.com>
	<20140702133358.0b4262cd@redhat.com>
	<alpine.DEB.2.02.1407021615550.5931@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, isimatu.yasuaki@jp.fujitsu.com, yinghai@kernel.org, riel@redhat.com, andi@firstfloor.org, akpm@linux-foundation.org

On Wed, 2 Jul 2014 16:20:47 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> On Wed, 2 Jul 2014, Luiz Capitulino wrote:
> 
> > > With this patch, the dmesg changes break one of my scripts that we use to 
> > > determine the start and end address of a node (doubly bad because there's 
> > > no sysfs interface to determine this otherwise and we have to do this at 
> > > boot to acquire the system topology).
> > > 
> > > Specifically, the removal of the
> > > 
> > > 	"Initmem setup node X [mem 0xstart-0xend]"
> > > 
> > > lines that are replaced when each node is onlined to
> > > 
> > > 	"Node 0 memory range 0xstart-0xend"
> > > 
> > > And if I just noticed this breakage when booting the latest -mm kernel, 
> > > I'm assuming I'm not the only person who is going to run into it.  Is it 
> > > possible to not change the dmesg output?
> > 
> > Sure. I can add back the original text. The only detail is that with this
> > patch that line is now printed a little bit later during boot and the
> > NODA_DATA lines also changed. Are you OK with that?
> > 
> 
> Yes, please.  I think it should be incremental on your patch since it's 
> already in -mm with " fix" appended so the title of the patch would be 
> "x86: numa: setup_node_data(): drop dead code and rename function fix" and 
> then Andrew can fold it into the original when sending it to the x86 
> maintainers.
> 
> > What's the guidelines on changing what's printed in dmesg?
> > 
> 
> That's the scary part, there doesn't seem to be any.  It's especially 
> crucial for things that only get printed once and aren't available 
> anywhere else at runtime; there was talk of adding a sysfs interface that 
> defines the start and end addresses of nodes but it's complicated because 
> nodes can overlap each other.  If that had been available years ago then I 
> don't think anybody would raise their hand about this issue.
> 
> These lines went under a smaller change a few years ago for 
> s/Bootmem/Initmem/.  I don't even have to look at the git history to know 
> that because it broke our scripts back then as well.  You just happened to 
> touch lines that I really care about and breaks my topology information :)  
> I wouldn't complain if it was just my userspace, but I have no doubt 
> others have parsed their dmesg in a similar way because people have 
> provided me with data that they retrieved by scraping the kernel log.

No problem. I'll send a patch shortly as you suggested.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
