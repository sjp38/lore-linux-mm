Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C7E4B6B003D
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 11:21:41 -0500 (EST)
Message-ID: <4B19370E.5030006@redhat.com>
Date: Fri, 04 Dec 2009 11:21:34 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/9] ksm: let shared pages be swappable
References: <20091202125501.GD28697@random.random> <20091203134610.586E.A69D9226@jp.fujitsu.com> <20091204135938.5886.A69D9226@jp.fujitsu.com> <20091204144540.GI28697@random.random>
In-Reply-To: <20091204144540.GI28697@random.random>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, Chris Wright <chrisw@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 12/04/2009 09:45 AM, Andrea Arcangeli wrote:

> I think it's fishy to ignore the page_referenced retval and I don't
> like the wipe_page_referenced concept. page_referenced should only be
> called when we're in presence of VM pressure that requires
> unmapping. And we should always re-add the page to active list head,
> if it was found referenced as retval of page_referenced.

You are wrong here, for scalability reasons I explained
to you half a dozen times before :)

I agree with the rest of your email, though.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
