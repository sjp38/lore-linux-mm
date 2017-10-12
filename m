Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 19CF76B0033
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 18:59:35 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id h200so4713059oib.18
        for <linux-mm@kvack.org>; Thu, 12 Oct 2017 15:59:35 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r15sor3221985otc.240.2017.10.12.15.59.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 12 Oct 2017 15:59:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1111804283.19946669.1507848765955.JavaMail.zimbra@redhat.com>
References: <20171012155027.3277-1-pagupta@redhat.com> <20171012155027.3277-3-pagupta@redhat.com>
 <CAPcyv4i7k6aYK_y4zZtL6p8sW-E_Ft58d2HuxO=dYciqQxaoLg@mail.gmail.com>
 <1567317495.19940236.1507843517318.JavaMail.zimbra@redhat.com>
 <CAPcyv4gkri7t+3Unf0sc9AHMnz-v9G_qV_bJppLjUUNAn7drrQ@mail.gmail.com>
 <1363955128.19944709.1507846719987.JavaMail.zimbra@redhat.com>
 <1507847249.21121.207.camel@redhat.com> <1111804283.19946669.1507848765955.JavaMail.zimbra@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 12 Oct 2017 15:59:33 -0700
Message-ID: <CAPcyv4jukEoKpH0OvZSNour+m5eQzuhiPAefAhYPqH2=f_ungA@mail.gmail.com>
Subject: Re: [RFC 2/2] KVM: add virtio-pmem driver
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pankaj Gupta <pagupta@redhat.com>
Cc: Rik van Riel <riel@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, KVM list <kvm@vger.kernel.org>, Qemu Developers <qemu-devel@nongnu.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Linux MM <linux-mm@kvack.org>, Jan Kara <jack@suse.cz>, Stefan Hajnoczi <stefanha@redhat.com>, Haozhong Zhang <haozhong.zhang@intel.com>, Nitesh Narayan Lal <nilal@redhat.com>, Kevin Wolf <kwolf@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Ross Zwisler <ross.zwisler@intel.com>, David Hildenbrand <david@redhat.com>, Xiao Guangrong <xiaoguangrong.eric@gmail.com>

On Thu, Oct 12, 2017 at 3:52 PM, Pankaj Gupta <pagupta@redhat.com> wrote:
> Dan,
>
> I have a query regarding below patch [*]. My assumption is its halted
> because of memory hotplug restructuring work? Anything I am missing
> here?
>
> [*] https://www.mail-archive.com/linux-nvdimm@lists.01.org/msg02978.html

It's fallen to the back of my queue since the original driving need of
platform firmware changing offsets from boot-to-boot is no longer an
issue. However, it does mean that you need to arrange for 128MB
aligned devm_memremap_pages() ranges for the foreseeable future.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
