Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 44EC26B0253
	for <linux-mm@kvack.org>; Mon,  8 Aug 2016 12:16:00 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id pp5so603020537pac.3
        for <linux-mm@kvack.org>; Mon, 08 Aug 2016 09:16:00 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id b64si37647350pfa.51.2016.08.08.09.15.58
        for <linux-mm@kvack.org>;
        Mon, 08 Aug 2016 09:15:58 -0700 (PDT)
Subject: Re: [PATCH v3 kernel 0/7] Extend virtio-balloon for fast
 (de)inflating & fast live migration
References: <1470638134-24149-1-git-send-email-liang.z.li@intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <57A8B03E.4080709@intel.com>
Date: Mon, 8 Aug 2016 09:15:58 -0700
MIME-Version: 1.0
In-Reply-To: <1470638134-24149-1-git-send-email-liang.z.li@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Liang Li <liang.z.li@intel.com>, linux-kernel@vger.kernel.org
Cc: virtualization@lists.linux-foundation.org, linux-mm@kvack.org, virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, quintela@redhat.com, dgilbert@redhat.com

On 08/07/2016 11:35 PM, Liang Li wrote:
> Dave Hansen suggested a new scheme to encode the data structure,
> because of additional complexity, it's not implemented in v3.

FWIW, I don't think it takes any additional complexity here, at least in
the guest implementation side.  The thing I suggested would just mean
explicitly calling out that there was a single bitmap instead of
implying it in the ABI.

Do you think the scheme I suggested is the way to go?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
