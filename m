Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id ED9596B0037
	for <linux-mm@kvack.org>; Thu, 21 Mar 2013 12:19:48 -0400 (EDT)
Message-ID: <514B336C.6070404@sr71.net>
Date: Thu, 21 Mar 2013 09:21:00 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCHv2, RFC 07/30] thp, mm: introduce mapping_can_have_hugepages()
 predicate
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com> <1363283435-7666-8-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1363283435-7666-8-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 03/14/2013 10:50 AM, Kirill A. Shutemov wrote:
> +static inline bool mapping_can_have_hugepages(struct address_space *m)
> +{
> +	if (IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE)) {
> +		gfp_t gfp_mask = mapping_gfp_mask(m);
> +		return !!(gfp_mask & __GFP_COMP);
> +	}
> +
> +	return false;
> +}

I did a quick search in all your patches and don't see __GFP_COMP
getting _set_ anywhere.  Am I missing something?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
