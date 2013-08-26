Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 164496B003D
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 17:49:46 -0400 (EDT)
Received: by mail-lb0-f180.google.com with SMTP id q8so1845648lbi.25
        for <linux-mm@kvack.org>; Mon, 26 Aug 2013 14:49:44 -0700 (PDT)
Date: Tue, 27 Aug 2013 01:49:40 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: unused swap offset / bad page map.
Message-ID: <20130826214940.GA7416@moon>
References: <20130823032127.GA5098@redhat.com>
 <CAJd=RBArkh3sKVoOJUZBLngXtJubjx4-a3G6s7Tn0N=Pr1gU4g@mail.gmail.com>
 <20130823035344.GB5098@redhat.com>
 <CAJd=RBBtY-nJfo9nzG5gtgcvB2bz+sxpK5kX33o1sLeLhvEU1Q@mail.gmail.com>
 <20130826190757.GB27768@redhat.com>
 <20130826201846.GA23724@moon>
 <20130826203702.GA15407@redhat.com>
 <20130826204203.GB23724@moon>
 <20130826213754.GN3814@moon>
 <20130826214244.GA21146@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130826214244.GA21146@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>
Cc: Hillf Danton <dhillf@gmail.com>, Linux-MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Mon, Aug 26, 2013 at 05:42:44PM -0400, Dave Jones wrote:
> 
> Yeah, for reproducing this bug, I'd stick to running it as a user, without --dangerous.
> you might still hit a few fairly-easy to trigger warn-on/printks. I run with
> this applied: http://paste.fedoraproject.org/34960/55323613/raw/ to make things
> a little less noisy.

Ah, thanks, pulling it in. Btw, have you seen this problem earlier than -rc4 at all?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
