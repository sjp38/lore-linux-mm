Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 6FA756B0007
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 19:49:42 -0500 (EST)
Received: by mail-wi0-f200.google.com with SMTP id hn14so2980681wib.7
        for <linux-mm@kvack.org>; Mon, 28 Jan 2013 16:49:40 -0800 (PST)
Message-ID: <51071CA0.801@ravellosystems.com>
Date: Tue, 29 Jan 2013 02:49:36 +0200
From: Izik Eidus <izik.eidus@ravellosystems.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/11] ksm: NUMA trees and page migration
References: <alpine.LNX.2.00.1301251747590.29196@eggly.anvils> <20130128155452.16882a6e.akpm@linux-foundation.org>
In-Reply-To: <20130128155452.16882a6e.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Anton Arapov <anton@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 01/29/2013 01:54 AM, Andrew Morton wrote:
> On Fri, 25 Jan 2013 17:53:10 -0800 (PST)
> Hugh Dickins <hughd@google.com> wrote:
>
>> Here's a KSM series
> Sanity check: do you have a feeling for how useful KSM is?
> Performance/space improvements for typical (or atypical) workloads?
> Are people using it?  Successfully?

Hi,
I think it mostly used for virtualization, I know at least two products 
that it use -
RHEV - RedHat enterprise virtualization, and my current place (Ravello 
Systems) that use it to do vm consolidation on top of cloud enviorments
(Run multiple unmodified VMs on top of one vm you get from ec2 / 
rackspace / what so ever), for Ravello it is highly critical in 
achieving high rate
of consolidation ratio...

>
> IOW, is it justifying itself?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
