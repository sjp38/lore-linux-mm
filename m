Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 2FE916B0036
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 07:21:59 -0400 (EDT)
Message-ID: <5215F441.6050905@suse.cz>
Date: Thu, 22 Aug 2013 13:21:37 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/7] Improving munlock() performance for large non-THP
 areas
References: <1376915022-12741-1-git-send-email-vbabka@suse.cz> <20130819154830.f863757c899bac69360a05b5@linux-foundation.org>
In-Reply-To: <20130819154830.f863757c899bac69360a05b5@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: =?ISO-8859-1?Q?J=F6rn_Engel?= <joern@logfs.org>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org

On 08/20/2013 12:48 AM, Andrew Morton wrote:
> On Mon, 19 Aug 2013 14:23:35 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:
> 
>> The goal of this patch series is to improve performance of munlock() of large
>> mlocked memory areas on systems without THP. This is motivated by reported very
>> long times of crash recovery of processes with such areas, where munlock() can
>> take several seconds. See http://lwn.net/Articles/548108/
> 
> That was a very nice patchset.  Not bad for a first effort ;)
> 
> Thanks, and welcome.

Thanks for the quick review and acceptance :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
