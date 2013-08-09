Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id E9AA46B0031
	for <linux-mm@kvack.org>; Fri,  9 Aug 2013 10:36:08 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <520170CA.4040409@sr71.net>
References: <1375582645-29274-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1375582645-29274-20-git-send-email-kirill.shutemov@linux.intel.com>
 <520170CA.4040409@sr71.net>
Subject: Re: [PATCH 19/23] truncate: support huge pages
Content-Transfer-Encoding: 7bit
Message-Id: <20130809143900.59722E0090@blue.fi.intel.com>
Date: Fri,  9 Aug 2013 17:39:00 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Ning Qu <quning@google.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Dave Hansen wrote:
> On 08/03/2013 07:17 PM, Kirill A. Shutemov wrote:
> > If a huge page is only partly in the range we zero out the part,
> > exactly like we do for partial small pages.
> 
> What's the logic behind this behaviour?  Seems like the kind of place
> that we would really want to be splitting pages.

split_huge_page() now truncates the file, so we need to break
truncate<->split interdependency at some point.

> Like I said before, I somehow like to rewrite your code. :)

Makes sense. Please, take a look on patch below.
