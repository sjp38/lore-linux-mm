Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 99D136B0038
	for <linux-mm@kvack.org>; Mon,  6 Apr 2015 14:57:35 -0400 (EDT)
Received: by wgin8 with SMTP id n8so34804925wgi.0
        for <linux-mm@kvack.org>; Mon, 06 Apr 2015 11:57:35 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id hz2si8957795wjb.15.2015.04.06.11.57.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Apr 2015 11:57:34 -0700 (PDT)
Message-ID: <5522D712.3090202@redhat.com>
Date: Mon, 06 Apr 2015 14:57:22 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC v7 2/2] mm: swapoff prototype: frontswap handling added
References: <20150319105545.GA8156@kelleynnn-virtual-machine> <20150324151034.ade239edc6386c206a311d82@linux-foundation.org>
In-Reply-To: <20150324151034.ade239edc6386c206a311d82@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Kelley Nielsen <kelleynnn@gmail.com>
Cc: linux-mm@kvack.org, riel@surriel.com, opw-kernel@googlegroups.com, hughd@google.com, jamieliu@google.com, sjenning@linux.vnet.ibm.com, sarah.a.sharp@intel.com

On 03/24/2015 06:10 PM, Andrew Morton wrote:
> On Thu, 19 Mar 2015 03:55:45 -0700 Kelley Nielsen <kelleynnn@gmail.com> wrote:
>
>> The prototype of the new swapoff (without the quadratic complexity)
>> presently ignores the frontswap case. Pass the count of
>> pages_to_unuse down the page table walks in try_to_unuse(),
>> and return from the walk when the desired number of pages
>> has been swapped back in.
>
> Does this fix the "TODO" in [1/2]?
>
> Do you think this patchset is ready for testing (while Hugh reviews it
> :)), or is there some deeper reason behind the "RFC"?

The patches look good to me, and this seems to
address the TODO from patch 1/2.

Acked-by: Rik van Riel <riel@redhat.com>


Kelley put in a heroic amount of effort tracking down
and fixing the corner cases I failed to anticipate
before putting this up as an OPW internship project.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
