Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 50BFC6B0253
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 11:05:12 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id l5so11368172oib.0
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 08:05:12 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l130sor502449oia.307.2017.10.20.08.05.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 20 Oct 2017 08:05:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171020080049.GA25471@infradead.org>
References: <20171012155027.3277-1-pagupta@redhat.com> <20171012155027.3277-3-pagupta@redhat.com>
 <20171017071633.GA9207@infradead.org> <1441791227.21027037.1508226056893.JavaMail.zimbra@redhat.com>
 <20171017080236.GA27649@infradead.org> <670833322.21037148.1508229041158.JavaMail.zimbra@redhat.com>
 <20171018130339.GB29767@stefanha-x1.localdomain> <CAPcyv4h6aFkyHhh4R4DTznbSCLf9CuBoszk0Q1gB5EKNcp_SeQ@mail.gmail.com>
 <20171019080149.GB10089@infradead.org> <CAPcyv4j=Cdp68C15HddKaErpve2UGRfSTiL6bHiS=3gQybz9pg@mail.gmail.com>
 <20171020080049.GA25471@infradead.org>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 20 Oct 2017 08:05:09 -0700
Message-ID: <CAPcyv4hHjCpm4AnLz2SdtjNMasV182Cw-jA+Cv9DjmE1Fa26kA@mail.gmail.com>
Subject: Re: [Qemu-devel] [RFC 2/2] KVM: add virtio-pmem driver
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Stefan Hajnoczi <stefanha@gmail.com>, Pankaj Gupta <pagupta@redhat.com>, Kevin Wolf <kwolf@redhat.com>, haozhong zhang <haozhong.zhang@intel.com>, Jan Kara <jack@suse.cz>, xiaoguangrong eric <xiaoguangrong.eric@gmail.com>, KVM list <kvm@vger.kernel.org>, David Hildenbrand <david@redhat.com>, linux-nvdimm <linux-nvdimm@ml01.01.org>, ross zwisler <ross.zwisler@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Qemu Developers <qemu-devel@nongnu.org>, Linux MM <linux-mm@kvack.org>, Stefan Hajnoczi <stefanha@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Nitesh Narayan Lal <nilal@redhat.com>

On Fri, Oct 20, 2017 at 1:00 AM, Christoph Hellwig <hch@infradead.org> wrote:
> On Thu, Oct 19, 2017 at 11:21:26AM -0700, Dan Williams wrote:
>> The difference is that nvdimm_flush() is not mandatory, and that the
>> platform will automatically perform the same flush at power-fail.
>> Applications should be able to assume that if they are using MAP_SYNC
>> that no other coordination with the kernel or the hypervisor is
>> necessary.
>>
>> Advertising this as a generic Persistent Memory range to the guest
>> means that the guest could theoretically use it with device-dax where
>> there is no driver or filesystem sync interface. The hypervisor will
>> be waiting for flush notifications and the guest will just issue cache
>> flushes and sfence instructions. So, as far as I can see we need to
>> differentiate this virtio-model from standard "Persistent Memory" to
>> the guest and remove the possibility of guests/applications making the
>> wrong assumption.
>
> So add a flag that it is not.  We already have the nd_volatile type,
> that is special.  For now only in Linux, but I think adding this type
> to the spec eventually would be very useful for efficiently exposing
> directly mappable device to VM guests.

Right, that's the same recommendation I gave.

    https://lists.gnu.org/archive/html/qemu-devel/2017-07/msg08404.html

...so maybe I'm misunderstanding your concern? It sounds like we're on
the same page.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
