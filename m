Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D99968D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 12:57:32 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH]mmap: add alignment for some variables
References: <1301277536.3981.27.camel@sli10-conroe>
Date: Mon, 28 Mar 2011 09:55:47 -0700
In-Reply-To: <1301277536.3981.27.camel@sli10-conroe> (Shaohua Li's message of
	"Mon, 28 Mar 2011 09:58:56 +0800")
Message-ID: <m2oc4v18x8.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

Shaohua Li <shaohua.li@intel.com> writes:

> Make some variables have correct alignment.

Nit: __read_mostly doesn't change alignment, just the section.
Please fix the description. Other than that it looks good.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
