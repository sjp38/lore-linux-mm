Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 253C86B0031
	for <linux-mm@kvack.org>; Mon,  2 Sep 2013 07:36:24 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <CACz4_2eY3cniz6mV-Nwi6jBEEOfETJs1GXrjHBppr=Grjnwiqw@mail.gmail.com>
References: <1375582645-29274-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1375582645-29274-6-git-send-email-kirill.shutemov@linux.intel.com>
 <CACz4_2eY3cniz6mV-Nwi6jBEEOfETJs1GXrjHBppr=Grjnwiqw@mail.gmail.com>
Subject: Re: [PATCH 05/23] thp: represent file thp pages in meminfo and
 friends
Content-Transfer-Encoding: 7bit
Message-Id: <20130902113616.6C750E0090@blue.fi.intel.com>
Date: Mon,  2 Sep 2013 14:36:16 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ning Qu <quning@google.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Ning Qu wrote:
> Hi, Kirill
> 
> I believe there is a typo in your previous commit, but you didn't include
> it in this series of patch set. Below is the link for the commit. I think
> you are trying to decrease the value NR_ANON_PAGES in page_remove_rmap, but
> it is currently adding the value instead when using __mod_zone_page_state.Let
> me know if you would like to fix it in your commit or you want another
> patch from me. Thanks!

The patch is already in Andrew's tree. I'll send a fix for that. Thanks.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
