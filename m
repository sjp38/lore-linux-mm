Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 299196B0092
	for <linux-mm@kvack.org>; Tue, 21 May 2013 18:56:44 -0400 (EDT)
Message-ID: <519BFBA9.7040007@sr71.net>
Date: Tue, 21 May 2013 15:56:41 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCHv4 27/39] x86-64, mm: proper alignment mappings with hugepages
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com> <1368321816-17719-28-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1368321816-17719-28-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 05/11/2013 06:23 PM, Kirill A. Shutemov wrote:
> +static inline unsigned long mapping_align_mask(struct address_space *mapping)
> +{
> +	if (mapping_can_have_hugepages(mapping))
> +		return PAGE_MASK & ~HPAGE_MASK;
> +	return get_align_mask();
> +}

get_align_mask() appears to be a bit more complicated to me than just a
plain old mask.  Are you sure you don't need to pick up any of its
behavior for the mapping_can_have_hugepages() case?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
