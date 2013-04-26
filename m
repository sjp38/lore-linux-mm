Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id BCACB6B0002
	for <linux-mm@kvack.org>; Thu, 25 Apr 2013 23:13:26 -0400 (EDT)
Message-ID: <5179F0AC.5020501@oracle.com>
Date: Thu, 25 Apr 2013 23:12:44 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: BUG in do_huge_pmd_wp_page
References: <51559150.3040407@oracle.com> <20130410080202.GB21292@blaptop> <5166CEDD.9050301@oracle.com> <20130411151323.89D40E0085@blue.fi.intel.com> <5166D355.2060103@oracle.com> <20130424154607.60e9b9895539eb5668d2f505@linux-foundation.org> <5179CF8F.7000702@oracle.com> <20130426020101.GA21162@redhat.com>
In-Reply-To: <20130426020101.GA21162@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Minchan Kim <minchan@kernel.org>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Mel Gorman <mgorman@suse.de>, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 04/25/2013 10:01 PM, Dave Jones wrote:
> On Thu, Apr 25, 2013 at 08:51:27PM -0400, Sasha Levin wrote:
>  > On 04/24/2013 06:46 PM, Andrew Morton wrote:
>  > > Guys, did this get fixed?
>  > 
>  > I've stopped seeing that during fuzzing, so I guess that it got fixed somehow...
> 
> We've had reports of users hitting this in 3.8
> 
> eg:
> https://bugzilla.redhat.com/show_bug.cgi?id=947985
> https://bugzilla.redhat.com/show_bug.cgi?id=956730 
> 
> I'm sure there are other reports of it too.
> 
> Would be good if we can figure out what fixed it (if it is actually fixed)
> for backporting to stable

If it's interesting to know I'll bisect it over the weekend...

Think it's enough to look at mm/ commits?


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
