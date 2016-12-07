Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id CB2CA6B0038
	for <linux-mm@kvack.org>; Wed,  7 Dec 2016 11:57:03 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id e9so104019171pgc.5
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 08:57:03 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id a96si24850703pli.200.2016.12.07.08.57.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Dec 2016 08:57:02 -0800 (PST)
From: Dave Hansen <dave.hansen@intel.com>
Subject: Re: [PATCH kernel v5 0/5] Extend virtio-balloon for fast
 (de)inflating & fast live migration
References: <1480495397-23225-1-git-send-email-liang.z.li@intel.com>
 <f67ca79c-ad34-59dd-835f-e7bc9dcaef58@redhat.com>
 <F2CBF3009FA73547804AE4C663CAB28E3A130C01@shsmsx102.ccr.corp.intel.com>
 <0b18c636-ee67-cbb4-1ba3-81a06150db76@redhat.com>
 <0b83db29-ebad-2a70-8d61-756d33e33a48@intel.com>
 <2171e091-46ee-decd-7348-772555d3a5e3@redhat.com>
Message-ID: <d3ff453c-56fa-19de-317c-1c82456f2831@intel.com>
Date: Wed, 7 Dec 2016 08:57:01 -0800
MIME-Version: 1.0
In-Reply-To: <2171e091-46ee-decd-7348-772555d3a5e3@redhat.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>, "Li, Liang Z" <liang.z.li@intel.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>
Cc: "mhocko@suse.com" <mhocko@suse.com>, "mst@redhat.com" <mst@redhat.com>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "dgilbert@redhat.com" <dgilbert@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

Removing silly virtio-dev@ list because it's bouncing mail...

On 12/07/2016 08:21 AM, David Hildenbrand wrote:
>> Li's current patches do that.  Well, maybe not pfn/length, but they do
>> take a pfn and page-order, which fits perfectly with the kernel's
>> concept of high-order pages.
> 
> So we can send length in powers of two. Still, I don't see any benefit
> over a simple pfn/len schema. But I'll have a more detailed look at the
> implementation first, maybe that will enlighten me :)

It is more space-efficient.  We're fitting the order into 6 bits, which
would allows the full 2^64 address space to be represented in one entry,
and leaves room for the bitmap size to be encoded as well, if we decide
we need a bitmap in the future.

If that was purely a length, we'd be limited to 64*4k pages per entry,
which isn't even a full large page.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
