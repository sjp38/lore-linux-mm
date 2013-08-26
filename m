Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id DA3596B0036
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 16:42:06 -0400 (EDT)
Received: by mail-lb0-f179.google.com with SMTP id v1so2719521lbd.38
        for <linux-mm@kvack.org>; Mon, 26 Aug 2013 13:42:05 -0700 (PDT)
Date: Tue, 27 Aug 2013 00:42:03 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: unused swap offset / bad page map.
Message-ID: <20130826204203.GB23724@moon>
References: <CAJd=RBA-UZmSTxNX63Vni+UPZBHwP4tvzE_qp1ZaHBqcNG7Fcw@mail.gmail.com>
 <20130821204901.GA19802@redhat.com>
 <CAJd=RBBNCf5_V-nHjK0gOqS4OLMszgB7Rg_WMf4DvL-De+ZdHA@mail.gmail.com>
 <20130823032127.GA5098@redhat.com>
 <CAJd=RBArkh3sKVoOJUZBLngXtJubjx4-a3G6s7Tn0N=Pr1gU4g@mail.gmail.com>
 <20130823035344.GB5098@redhat.com>
 <CAJd=RBBtY-nJfo9nzG5gtgcvB2bz+sxpK5kX33o1sLeLhvEU1Q@mail.gmail.com>
 <20130826190757.GB27768@redhat.com>
 <20130826201846.GA23724@moon>
 <20130826203702.GA15407@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130826203702.GA15407@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Hillf Danton <dhillf@gmail.com>, Linux-MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Mon, Aug 26, 2013 at 04:37:02PM -0400, Dave Jones wrote:
> 
> Try adding the -C64 to the invocation in scripts/test-multi.sh,
> and perhaps up'ing the NR_PROCESSES variable there too.

Thanks! I'll ping you if I manage to crash my instance.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
