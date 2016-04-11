Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id 275F96B0005
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 14:37:46 -0400 (EDT)
Received: by mail-qg0-f49.google.com with SMTP id f52so152019200qga.3
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 11:37:46 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b16si21316851qge.103.2016.04.11.11.37.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 11:37:45 -0700 (PDT)
Date: Mon, 11 Apr 2016 20:37:38 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [Lsf] [Lsf-pc] [LSF/MM TOPIC] Generic page-pool recycle
 facility?
Message-ID: <20160411203738.58a6adb2@redhat.com>
In-Reply-To: <20160411174625.GH1845@indiana.gru.redhat.com>
References: <1460034425.20949.7.camel@HansenPartnership.com>
	<20160407161715.52635cac@redhat.com>
	<20160411085819.GE21128@suse.de>
	<20160411142639.1c5e520b@redhat.com>
	<20160411130826.GB32073@techsingularity.net>
	<20160411162047.GJ2781@linux.intel.com>
	<20160411174625.GH1845@indiana.gru.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
Cc: Matthew Wilcox <willy@linux.intel.com>, Mel Gorman <mgorman@techsingularity.net>, James Bottomley <James.Bottomley@HansenPartnership.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Brenden Blanco <bblanco@plumgrid.com>, lsf@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Tom Herbert <tom@herbertland.com>, lsf-pc@lists.linux-foundation.org, Alexei Starovoitov <alexei.starovoitov@gmail.com>, brouer@redhat.com

On Mon, 11 Apr 2016 14:46:25 -0300
Thadeu Lima de Souza Cascardo <cascardo@redhat.com> wrote:

> So, Jesper, please take into consideration that this pool design
> would rather be per device. Otherwise, we allow some device to write
> into another's device/driver memory.

Yes, that was my intended use.  I want to have a page-pool per device.
I actually, want to go as far as a page-pool per NIC HW RX-ring queue.

Because the other use-case for the page-pool is zero-copy RX.

The NIC HW trick is that we today can create a HW filter in the NIC
(via ethtool) and place that traffic into a separate RX queue in the
NIC.  Lets say matching NFS traffic or guest traffic. Then we can allow
RX zero-copy of these pages, into the application/guest, somehow
binding it to RX queue, e.g. introducing a "cross-domain-id" in the
page-pool page that need to match.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
