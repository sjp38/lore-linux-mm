Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 968656B0033
	for <linux-mm@kvack.org>; Sun, 22 Jan 2017 19:22:12 -0500 (EST)
Received: by mail-yw0-f198.google.com with SMTP id l19so182680753ywc.5
        for <linux-mm@kvack.org>; Sun, 22 Jan 2017 16:22:12 -0800 (PST)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id 126si2816593ybq.282.2017.01.22.16.22.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Jan 2017 16:22:11 -0800 (PST)
Date: Sun, 22 Jan 2017 19:21:58 -0500
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] I/O error handling and fsync()
Message-ID: <20170123002158.xe7r7us2buc37ybq@thunk.org>
References: <20170110160224.GC6179@noname.redhat.com>
 <87k2a2ig2c.fsf@notabene.neil.brown.name>
 <20170113110959.GA4981@noname.redhat.com>
 <20170113142154.iycjjhjujqt5u2ab@thunk.org>
 <20170113160022.GC4981@noname.redhat.com>
 <87mveufvbu.fsf@notabene.neil.brown.name>
 <1484568855.2719.3.camel@poochiereds.net>
 <87o9yyemud.fsf@notabene.neil.brown.name>
 <1485127917.5321.1.camel@poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1485127917.5321.1.camel@poochiereds.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: NeilBrown <neilb@suse.com>, Kevin Wolf <kwolf@redhat.com>, Rik van Riel <riel@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, lsf-pc@lists.linux-foundation.org, Ric Wheeler <rwheeler@redhat.com>

On Sun, Jan 22, 2017 at 06:31:57PM -0500, Jeff Layton wrote:
> 
> Ahh, sorry if I wasn't clear.
> 
> I know Kevin posed this topic in the context of QEMU/KVM, and I figure
> that running virt guests (themselves doing all sorts of workloads) is a
> pretty common setup these days. That was what I meant by "use case"
> here. Obviously there are many other workloads that could benefit from
> (or be harmed by) changes in this area.
> 
> Still, I think that looking at QEMU/KVM as a "application" and
> considering what we can do to help optimize that case could be helpful
> here (and might also be helpful for other workloads).

Well, except for QEMU/KVM, Kevin has already confirmed that using
Direct I/O is a completely viable solution.  (And I'll add it solves a
bunch of other problems, including page cache efficiency....)

					- Ted


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
