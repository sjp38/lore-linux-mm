Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id EA1D86B0009
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 13:24:34 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id g138so19077453qke.22
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 10:24:34 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id k7si1119471qkb.395.2018.04.26.10.24.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Apr 2018 10:24:34 -0700 (PDT)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [Qemu-devel] [RFC v2 1/2] virtio: add pmem driver
References: <20180425112415.12327-1-pagupta@redhat.com>
	<20180425112415.12327-2-pagupta@redhat.com>
	<CAPcyv4hvrB08XPTbVK0xT2_1Xmaid=-v3OMxJVDTNwQucsOHLA@mail.gmail.com>
	<CAPcyv4hiowWozV527sQA_e4fdgCYbD6xfG==vepAqu0hxQEQcw@mail.gmail.com>
	<x49o9i6885e.fsf@segfault.boston.devel.redhat.com>
	<1499190564.23017177.1524762938762.JavaMail.zimbra@redhat.com>
Date: Thu, 26 Apr 2018 13:24:17 -0400
In-Reply-To: <1499190564.23017177.1524762938762.JavaMail.zimbra@redhat.com>
	(Pankaj Gupta's message of "Thu, 26 Apr 2018 13:15:38 -0400 (EDT)")
Message-ID: <x49in8d6fum.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pankaj Gupta <pagupta@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, KVM list <kvm@vger.kernel.org>, David Hildenbrand <david@redhat.com>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Ross Zwisler <ross.zwisler@intel.com>, Qemu Developers <qemu-devel@nongnu.org>, lcapitulino@redhat.com, Linux MM <linux-mm@kvack.org>, niteshnarayanlal@hotmail.com, "Michael S. Tsirkin" <mst@redhat.com>, Christoph Hellwig <hch@infradead.org>, Marcel Apfelbaum <marcel@redhat.com>, Nitesh Narayan Lal <nilal@redhat.com>, Haozhong Zhang <haozhong.zhang@intel.com>, Rik van Riel <riel@surriel.com>, Stefan Hajnoczi <stefanha@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Kevin Wolf <kwolf@redhat.com>, Xiao Guangrong <xiaoguangrong.eric@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Igor Mammedov <imammedo@redhat.com>

Pankaj Gupta <pagupta@redhat.com> writes:

>> Ideally, qemu (seabios?) would advertise a platform capabilities
>> sub-table that doesn't fill in the flush bits.
>
> Could you please elaborate on this, how its related to disabling
> MAP_SYNC? We are not doing entire nvdimm device emulation. 

My mistake.  If you're not providing an NFIT, then you can ignore this
comment.  I'll have a closer look at your patches next week.

-Jeff
