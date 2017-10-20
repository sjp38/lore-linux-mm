Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6059B6B0038
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 12:06:50 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e64so10837988pfk.0
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 09:06:50 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id c41si739258plj.679.2017.10.20.09.06.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Oct 2017 09:06:48 -0700 (PDT)
Date: Fri, 20 Oct 2017 09:06:44 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [Qemu-devel] [RFC 2/2] KVM: add virtio-pmem driver
Message-ID: <20171020160644.GA27946@infradead.org>
References: <20171017071633.GA9207@infradead.org>
 <1441791227.21027037.1508226056893.JavaMail.zimbra@redhat.com>
 <20171017080236.GA27649@infradead.org>
 <670833322.21037148.1508229041158.JavaMail.zimbra@redhat.com>
 <20171018130339.GB29767@stefanha-x1.localdomain>
 <CAPcyv4h6aFkyHhh4R4DTznbSCLf9CuBoszk0Q1gB5EKNcp_SeQ@mail.gmail.com>
 <20171019080149.GB10089@infradead.org>
 <CAPcyv4j=Cdp68C15HddKaErpve2UGRfSTiL6bHiS=3gQybz9pg@mail.gmail.com>
 <20171020080049.GA25471@infradead.org>
 <CAPcyv4hHjCpm4AnLz2SdtjNMasV182Cw-jA+Cv9DjmE1Fa26kA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4hHjCpm4AnLz2SdtjNMasV182Cw-jA+Cv9DjmE1Fa26kA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@infradead.org>, Kevin Wolf <kwolf@redhat.com>, Jan Kara <jack@suse.cz>, xiaoguangrong eric <xiaoguangrong.eric@gmail.com>, KVM list <kvm@vger.kernel.org>, Pankaj Gupta <pagupta@redhat.com>, Stefan Hajnoczi <stefanha@gmail.com>, David Hildenbrand <david@redhat.com>, ross zwisler <ross.zwisler@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Qemu Developers <qemu-devel@nongnu.org>, Linux MM <linux-mm@kvack.org>, Stefan Hajnoczi <stefanha@redhat.com>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Paolo Bonzini <pbonzini@redhat.com>, Nitesh Narayan Lal <nilal@redhat.com>

On Fri, Oct 20, 2017 at 08:05:09AM -0700, Dan Williams wrote:
> Right, that's the same recommendation I gave.
> 
>     https://lists.gnu.org/archive/html/qemu-devel/2017-07/msg08404.html
> 
> ...so maybe I'm misunderstanding your concern? It sounds like we're on
> the same page.

Yes, the above is exactly what I think we should do it.  And in many
ways virtio seems overkill if we could just have a hypercall or doorbell
page as the queueing infrastructure in virtio shouldn't really be
needed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
