Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 91CED6B004D
	for <linux-mm@kvack.org>; Tue,  8 Jan 2013 07:25:48 -0500 (EST)
Date: Tue, 8 Jan 2013 13:25:36 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 0/2] pageattr fixes for pmd/pte_present
Message-ID: <20130108122536.GD9163@redhat.com>
References: <1355767224-13298-1-git-send-email-aarcange@redhat.com>
 <1357441197.9001.6.camel@kernel.cn.ibm.com>
 <20130107135344.5ca426ca.akpm@linux-foundation.org>
 <50EB4455.60808@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50EB4455.60808@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Simon Jeons <simon.jeons@gmail.com>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, Shaohua Li <shaohua.li@intel.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>

Hi,

On Mon, Jan 07, 2013 at 01:55:33PM -0800, H. Peter Anvin wrote:
> On 01/07/2013 01:53 PM, Andrew Morton wrote:
> >>
> >> What's the status of these two patches?
> > 
> > I expect they fell through the christmas cracks.  I added them to my
> > (getting large) queue of x86 patches for consideration by the x86
> > maintainers.
> 
> Yes, I'm just coming back online today, and needless to say, I have a
> *huge* backlog.
> 
> > Why do you ask?  It seems the bug is a pretty minor one and that we
> > need only fix it in 3.8 or even 3.9.  Is that supposition incorrect?
> 
> I would like to know this as well.

It is a minor regression that was reported. The only way to notice it
should be to use the crash tool or other non standard root stuff. So
it shouldn't be too urgent.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
