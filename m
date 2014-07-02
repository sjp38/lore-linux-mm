Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f181.google.com (mail-ob0-f181.google.com [209.85.214.181])
	by kanga.kvack.org (Postfix) with ESMTP id 5B7936B0031
	for <linux-mm@kvack.org>; Wed,  2 Jul 2014 15:04:55 -0400 (EDT)
Received: by mail-ob0-f181.google.com with SMTP id wp4so12926980obc.12
        for <linux-mm@kvack.org>; Wed, 02 Jul 2014 12:04:55 -0700 (PDT)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id b5si35620539obq.91.2014.07.02.12.04.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 02 Jul 2014 12:04:54 -0700 (PDT)
Message-ID: <1404327890.13372.4.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH 0/7] [RESEND][v4] x86: rework tlb range flushing code
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Wed, 02 Jul 2014 12:04:50 -0700
In-Reply-To: <20140701164845.8D1A5702@viggo.jf.intel.com>
References: <20140701164845.8D1A5702@viggo.jf.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, hpa@zytor.com, mingo@redhat.com, tglx@linutronix.de, x86@kernel.org

On Tue, 2014-07-01 at 09:48 -0700, Dave Hansen wrote:
> x86 Maintainers,
> 
> Could this get picked up in to the x86 tree, please?  That way,
> it will get plenty of time to bake before the 3.17 merge window.

I had originally tried out this series (~v1, v2 iirc) on large KVM
configurations. Setting the TLB flush tunable to 33 seemed prudent and
didn't cause anything weird. Feel free to add my:

Tested-by: Davidlohr Bueso <davidlohr@hp.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
