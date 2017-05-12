Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 190056B02EE
	for <linux-mm@kvack.org>; Fri, 12 May 2017 12:57:18 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id k91so41325887ioi.3
        for <linux-mm@kvack.org>; Fri, 12 May 2017 09:57:18 -0700 (PDT)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id e193si4085803itc.118.2017.05.12.09.57.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 May 2017 09:57:17 -0700 (PDT)
Date: Fri, 12 May 2017 11:57:15 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [patch 2/2] MM: allow per-cpu vmstat_threshold and vmstat_worker
 configuration
In-Reply-To: <20170512161915.GA4185@amt.cnet>
Message-ID: <alpine.DEB.2.20.1705121154240.23503@east.gentwo.org>
References: <20170425135717.375295031@redhat.com> <20170425135846.203663532@redhat.com> <20170502102836.4a4d34ba@redhat.com> <20170502165159.GA5457@amt.cnet> <20170502131527.7532fc2e@redhat.com> <alpine.DEB.2.20.1705111035560.2894@east.gentwo.org>
 <20170512122704.GA30528@amt.cnet> <alpine.DEB.2.20.1705121002310.22243@east.gentwo.org> <20170512154026.GA3556@amt.cnet> <alpine.DEB.2.20.1705121103120.22831@east.gentwo.org> <20170512161915.GA4185@amt.cnet>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marcelo Tosatti <mtosatti@redhat.com>
Cc: Luiz Capitulino <lcapitulino@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Linux RT Users <linux-rt-users@vger.kernel.org>, cmetcalf@mellanox.com

On Fri, 12 May 2017, Marcelo Tosatti wrote:

> > What exactly is the issue you are seeing and want to address? I think we
> > have similar aims and as far as I know the current situation is already
> > good enough for what you may need. You may just not be aware of how to
> > configure this.
>
> I want to disable vmstat worker thread completly from an isolated CPU.
> Because it adds overhead to a latency target, target which
> the lower the better.

NOHZ already does that. I wanted to know what your problem is that you
see. The latency issue has already been solved as far as I can tell .
Please tell me why the existing solutions are not sufficient for you.

> > I doubt that doing inline updates will do much good compared to what we
> > already have and what the dataplan mode can do.
>
> Can the dataplan mode disable vmstat worker thread completly on a given
> CPU?

That already occurs when you call quiet_vmstat() and is used by the NOHZ
logic. Configure that correctly and you should be fine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
