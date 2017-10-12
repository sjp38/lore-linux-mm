Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8997F6B0033
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 19:07:31 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id j58so10441649qtj.7
        for <linux-mm@kvack.org>; Thu, 12 Oct 2017 16:07:31 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o64si196404qkb.201.2017.10.12.16.07.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Oct 2017 16:07:30 -0700 (PDT)
Date: Thu, 12 Oct 2017 19:07:27 -0400 (EDT)
From: Pankaj Gupta <pagupta@redhat.com>
Message-ID: <1755911209.19947416.1507849647657.JavaMail.zimbra@redhat.com>
In-Reply-To: <CAPcyv4jukEoKpH0OvZSNour+m5eQzuhiPAefAhYPqH2=f_ungA@mail.gmail.com>
References: <20171012155027.3277-1-pagupta@redhat.com> <CAPcyv4i7k6aYK_y4zZtL6p8sW-E_Ft58d2HuxO=dYciqQxaoLg@mail.gmail.com> <1567317495.19940236.1507843517318.JavaMail.zimbra@redhat.com> <CAPcyv4gkri7t+3Unf0sc9AHMnz-v9G_qV_bJppLjUUNAn7drrQ@mail.gmail.com> <1363955128.19944709.1507846719987.JavaMail.zimbra@redhat.com> <1507847249.21121.207.camel@redhat.com> <1111804283.19946669.1507848765955.JavaMail.zimbra@redhat.com> <CAPcyv4jukEoKpH0OvZSNour+m5eQzuhiPAefAhYPqH2=f_ungA@mail.gmail.com>
Subject: Re: [RFC 2/2] KVM: add virtio-pmem driver
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, KVM list <kvm@vger.kernel.org>, Qemu Developers <qemu-devel@nongnu.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Linux MM <linux-mm@kvack.org>, Jan Kara <jack@suse.cz>, Stefan Hajnoczi <stefanha@redhat.com>, Haozhong Zhang <haozhong.zhang@intel.com>, Nitesh Narayan Lal <nilal@redhat.com>, Kevin Wolf <kwolf@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Ross Zwisler <ross.zwisler@intel.com>, David Hildenbrand <david@redhat.com>, Xiao Guangrong <xiaoguangrong.eric@gmail.com>


> > Dan,
> >
> > I have a query regarding below patch [*]. My assumption is its halted
> > because of memory hotplug restructuring work? Anything I am missing
> > here?
> >
> > [*] https://www.mail-archive.com/linux-nvdimm@lists.01.org/msg02978.html
> 
> It's fallen to the back of my queue since the original driving need of
> platform firmware changing offsets from boot-to-boot is no longer an
> issue. However, it does mean that you need to arrange for 128MB
> aligned devm_memremap_pages() ranges for the foreseeable future.

o.k I will provide 128MB aligned pages to devm_memremap_pages() function.

Thanks,
Pankaj

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
