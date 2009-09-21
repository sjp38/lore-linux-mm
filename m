Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 80F456B0096
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 14:05:02 -0400 (EDT)
Received: by fxm2 with SMTP id 2so2332890fxm.4
        for <linux-mm@kvack.org>; Mon, 21 Sep 2009 11:05:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.1.10.0909211349530.3106@V090114053VZO-1>
References: <1253549426-917-1-git-send-email-mel@csn.ul.ie>
	 <20090921174656.GS12726@csn.ul.ie>
	 <alpine.DEB.1.10.0909211349530.3106@V090114053VZO-1>
Date: Mon, 21 Sep 2009 21:05:01 +0300
Message-ID: <84144f020909211105p4772920at1a20d286710d19b8@mail.gmail.com>
Subject: Re: [RFC PATCH 0/3] Fix SLQB on memoryless configurations V2
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@suse.de>, heiko.carstens@de.ibm.com, sachinp@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Mon, Sep 21, 2009 at 8:54 PM, Christoph Lameter
<cl@linux-foundation.org> wrote:
> Lets just keep SLQB back until the basic issues with memoryless nodes are
> resolved. There does not seem to be an easy way to deal with this. Some
> thought needs to go into how memoryless node handling relates to per cpu
> lists and locking. List handling issues need to be addressed before SLQB.
> can work reliably. The same issues can surface on x86 platforms with weird
> NUMA memory setups.
>
> Or just allow SLQB for !NUMA configurations and merge it now.

I'm holding on to it until the issues are resolved.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
