Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 144F36B0005
	for <linux-mm@kvack.org>; Sat, 23 Feb 2013 20:40:05 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id bj3so1139100pad.6
        for <linux-mm@kvack.org>; Sat, 23 Feb 2013 17:40:05 -0800 (PST)
Message-ID: <51296F49.40103@gmail.com>
Date: Sun, 24 Feb 2013 09:39:21 +0800
From: Ric Mason <ric.masonn@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/7] ksm: responses to NUMA review
References: <alpine.LNX.2.00.1302210013120.17843@eggly.anvils> <5126E987.7020809@gmail.com> <alpine.LNX.2.00.1302221227530.6100@eggly.anvils>
In-Reply-To: <alpine.LNX.2.00.1302221227530.6100@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 02/23/2013 04:38 AM, Hugh Dickins wrote:
> On Fri, 22 Feb 2013, Ric Mason wrote:
>> On 02/21/2013 04:17 PM, Hugh Dickins wrote:
>>> Here's a second KSM series, based on mmotm 2013-02-19-17-20: partly in
>>> response to Mel's review feedback, partly fixes to issues that I found
>>> myself in doing more review and testing.  None of the issues fixed are
>>> truly show-stoppers, though I would prefer them fixed sooner than later.
>> Do you have any ideas ksm support page cache and tmpfs?
> No.  It's only been asked as a hypothetical question: I don't know of
> anyone actually needing it, and I wouldn't have time to do it myself.
>
> It would be significantly more invasive than just dealing with anonymous
> memory: with anon, we already have the infrastructure for read-only pages,
> but we don't at present have any notion of read-only pagecache.
>
> Just doing it in tmpfs?  Well, yes, that might be easier: since v3.1's
> radix_tree rework, shmem/tmpfs mostly goes through its own interfaces
> to pagecache, so read-only pagecache, and hence KSM, might be easier
> to implement there than more generally.

Ok, are there potential users to take advantage of it?

>
> Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
