Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 65D746B0253
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 18:52:27 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id pp5so17831933pac.3
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 15:52:27 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id rx5si8585874pab.143.2016.07.27.15.52.26
        for <linux-mm@kvack.org>;
        Wed, 27 Jul 2016 15:52:26 -0700 (PDT)
Subject: Re: [PATCH v2 repost 3/7] mm: add a function to get the max pfn
References: <1469582616-5729-1-git-send-email-liang.z.li@intel.com>
 <1469582616-5729-4-git-send-email-liang.z.li@intel.com>
 <20160728010729-mutt-send-email-mst@kernel.org>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <57993B16.5010703@intel.com>
Date: Wed, 27 Jul 2016 15:52:06 -0700
MIME-Version: 1.0
In-Reply-To: <20160728010729-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>, Liang Li <liang.z.li@intel.com>
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, dgilbert@redhat.com, quintela@redhat.com, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Paolo Bonzini <pbonzini@redhat.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Amit Shah <amit.shah@redhat.com>

On 07/27/2016 03:08 PM, Michael S. Tsirkin wrote:
>> > +unsigned long get_max_pfn(void)
>> > +{
>> > +	return max_pfn;
>> > +}
>> > +EXPORT_SYMBOL(get_max_pfn);
>> > +
> 
> This needs a coment that this can change at any time.
> So it's only good as a hint e.g. for sizing data structures.

Or, if we limit the batches to 1GB like you suggested earlier, then we
might not even need this exported.  It would mean that in the worst
case, we temporarily waste 28k out of the 32k allocation for a small VM
that had <128MB of memory.

That seems like a small price to pay for not having to track max_pfn
anywhere.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
