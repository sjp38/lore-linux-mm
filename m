Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1F96B6B0033
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 16:42:44 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id s185so4762024oif.3
        for <linux-mm@kvack.org>; Thu, 12 Oct 2017 13:42:44 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 96sor4813705ott.89.2017.10.12.13.42.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 12 Oct 2017 13:42:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171012155027.3277-2-pagupta@redhat.com>
References: <20171012155027.3277-1-pagupta@redhat.com> <20171012155027.3277-2-pagupta@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 12 Oct 2017 13:42:42 -0700
Message-ID: <CAPcyv4jdWUeoF1PxWhXx3vciLmOL9AyW_yPq0W6DRFe3RP2fkA@mail.gmail.com>
Subject: Re: [RFC 1/2] pmem: Move reusable code to base header files
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pankaj Gupta <pagupta@redhat.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, KVM list <kvm@vger.kernel.org>, Qemu Developers <qemu-devel@nongnu.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Linux MM <linux-mm@kvack.org>, Jan Kara <jack@suse.cz>, Stefan Hajnoczi <stefanha@redhat.com>, Rik van Riel <riel@redhat.com>, Haozhong Zhang <haozhong.zhang@intel.com>, Nitesh Narayan Lal <nilal@redhat.com>, Kevin Wolf <kwolf@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, "Zwisler, Ross" <ross.zwisler@intel.com>, David Hildenbrand <david@redhat.com>, Xiao Guangrong <xiaoguangrong.eric@gmail.com>

On Thu, Oct 12, 2017 at 8:50 AM, Pankaj Gupta <pagupta@redhat.com> wrote:
>  This patch moves common code to base header files
>  so that it can be used for both ACPI pmem and VIRTIO pmem
>  drivers. More common code needs to be moved out in future
>  based on functionality required for virtio_pmem driver and
>  coupling of code with existing ACPI pmem driver.
>
> Signed-off-by: Pankaj Gupta <pagupta@redhat.com>
[..]
> diff --git a/include/linux/pmem_common.h b/include/linux/pmem_common.h
> new file mode 100644
> index 000000000000..e2e718c74b3f
> --- /dev/null
> +++ b/include/linux/pmem_common.h

This should be a common C file, not a header.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
