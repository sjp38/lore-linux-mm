Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id C0E946B0253
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 12:11:15 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id e123so11565593oig.14
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 09:11:15 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f24sor645583otd.253.2017.10.20.09.11.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 20 Oct 2017 09:11:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171020160644.GA27946@infradead.org>
References: <20171017071633.GA9207@infradead.org> <1441791227.21027037.1508226056893.JavaMail.zimbra@redhat.com>
 <20171017080236.GA27649@infradead.org> <670833322.21037148.1508229041158.JavaMail.zimbra@redhat.com>
 <20171018130339.GB29767@stefanha-x1.localdomain> <CAPcyv4h6aFkyHhh4R4DTznbSCLf9CuBoszk0Q1gB5EKNcp_SeQ@mail.gmail.com>
 <20171019080149.GB10089@infradead.org> <CAPcyv4j=Cdp68C15HddKaErpve2UGRfSTiL6bHiS=3gQybz9pg@mail.gmail.com>
 <20171020080049.GA25471@infradead.org> <CAPcyv4hHjCpm4AnLz2SdtjNMasV182Cw-jA+Cv9DjmE1Fa26kA@mail.gmail.com>
 <20171020160644.GA27946@infradead.org>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 20 Oct 2017 09:11:13 -0700
Message-ID: <CAPcyv4iASygtEJrBL07ve3p4na_XvuoxV7yA0m4R1XfsyvNPJA@mail.gmail.com>
Subject: Re: [Qemu-devel] [RFC 2/2] KVM: add virtio-pmem driver
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Kevin Wolf <kwolf@redhat.com>, Jan Kara <jack@suse.cz>, xiaoguangrong eric <xiaoguangrong.eric@gmail.com>, KVM list <kvm@vger.kernel.org>, Pankaj Gupta <pagupta@redhat.com>, Stefan Hajnoczi <stefanha@gmail.com>, David Hildenbrand <david@redhat.com>, ross zwisler <ross.zwisler@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Qemu Developers <qemu-devel@nongnu.org>, Linux MM <linux-mm@kvack.org>, Stefan Hajnoczi <stefanha@redhat.com>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Paolo Bonzini <pbonzini@redhat.com>, Nitesh Narayan Lal <nilal@redhat.com>

On Fri, Oct 20, 2017 at 9:06 AM, Christoph Hellwig <hch@infradead.org> wrote:
> On Fri, Oct 20, 2017 at 08:05:09AM -0700, Dan Williams wrote:
>> Right, that's the same recommendation I gave.
>>
>>     https://lists.gnu.org/archive/html/qemu-devel/2017-07/msg08404.html
>>
>> ...so maybe I'm misunderstanding your concern? It sounds like we're on
>> the same page.
>
> Yes, the above is exactly what I think we should do it.  And in many
> ways virtio seems overkill if we could just have a hypercall or doorbell
> page as the queueing infrastructure in virtio shouldn't really be
> needed.

Ah ok, yes, get rid of the virtio-pmem driver and just make
nvdimm_flush() do a hypercall based on region-type flag.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
