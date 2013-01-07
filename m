Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id C00926B005A
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 16:55:34 -0500 (EST)
Message-ID: <50EB4455.60808@linux.intel.com>
Date: Mon, 07 Jan 2013 13:55:33 -0800
From: "H. Peter Anvin" <hpa@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/2] pageattr fixes for pmd/pte_present
References: <1355767224-13298-1-git-send-email-aarcange@redhat.com> <1357441197.9001.6.camel@kernel.cn.ibm.com> <20130107135344.5ca426ca.akpm@linux-foundation.org>
In-Reply-To: <20130107135344.5ca426ca.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Simon Jeons <simon.jeons@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, Shaohua Li <shaohua.li@intel.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>

On 01/07/2013 01:53 PM, Andrew Morton wrote:
>>
>> What's the status of these two patches?
> 
> I expect they fell through the christmas cracks.  I added them to my
> (getting large) queue of x86 patches for consideration by the x86
> maintainers.

Yes, I'm just coming back online today, and needless to say, I have a
*huge* backlog.

> Why do you ask?  It seems the bug is a pretty minor one and that we
> need only fix it in 3.8 or even 3.9.  Is that supposition incorrect?

I would like to know this as well.

	-hpa




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
