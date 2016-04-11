Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 8655E6B0005
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 14:53:15 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id ot11so42991382pab.1
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 11:53:15 -0700 (PDT)
Received: from na01-bn1-obe.outbound.protection.outlook.com (mail-bn1on0057.outbound.protection.outlook.com. [157.56.110.57])
        by mx.google.com with ESMTPS id e3si5066972pas.186.2016.04.11.11.53.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 11 Apr 2016 11:53:14 -0700 (PDT)
Subject: Re: [Lsf] [Lsf-pc] [LSF/MM TOPIC] Generic page-pool recycle facility?
References: <1460034425.20949.7.camel@HansenPartnership.com>
 <20160407161715.52635cac@redhat.com> <20160411085819.GE21128@suse.de>
 <20160411142639.1c5e520b@redhat.com>
 <20160411130826.GB32073@techsingularity.net>
 <20160411162047.GJ2781@linux.intel.com>
 <20160411174625.GH1845@indiana.gru.redhat.com>
 <20160411203738.58a6adb2@redhat.com>
From: Bart Van Assche <bart.vanassche@sandisk.com>
Message-ID: <570BF296.1080101@sandisk.com>
Date: Mon, 11 Apr 2016 11:53:10 -0700
MIME-Version: 1.0
In-Reply-To: <20160411203738.58a6adb2@redhat.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>, Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
Cc: "lsf@lists.linux-foundation.org" <lsf@lists.linux-foundation.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Brenden Blanco <bblanco@plumgrid.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, linux-mm <linux-mm@kvack.org>, Mel
 Gorman <mgorman@suse.de>, Tom Herbert <tom@herbertland.com>, Matthew Wilcox <willy@linux.intel.com>, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Alexei Starovoitov <alexei.starovoitov@gmail.com>

On 04/11/2016 11:37 AM, Jesper Dangaard Brouer wrote:
> On Mon, 11 Apr 2016 14:46:25 -0300
> Thadeu Lima de Souza Cascardo <cascardo@redhat.com> wrote:
>
>> So, Jesper, please take into consideration that this pool design
>> would rather be per device. Otherwise, we allow some device to write
>> into another's device/driver memory.
>
> Yes, that was my intended use.  I want to have a page-pool per device.
> I actually, want to go as far as a page-pool per NIC HW RX-ring queue.
>
> Because the other use-case for the page-pool is zero-copy RX.
>
> The NIC HW trick is that we today can create a HW filter in the NIC
> (via ethtool) and place that traffic into a separate RX queue in the
> NIC.  Lets say matching NFS traffic or guest traffic. Then we can allow
> RX zero-copy of these pages, into the application/guest, somehow
> binding it to RX queue, e.g. introducing a "cross-domain-id" in the
> page-pool page that need to match.

I think it is important to keep in mind that using a page pool for 
zero-copy RX is specific to protocols that are based on TCP/IP. 
Protocols like FC, SRP and iSER have been designed such that the side 
that allocates the buffers also initiates the data transfer (the target 
side). With TCP/IP however transferring data and allocating receive 
buffers happens by opposite sides of the connection.

Bart.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
