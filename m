Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 547416B005A
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 08:40:22 -0400 (EDT)
Received: by vbkv13 with SMTP id v13so1700282vbk.14
        for <linux-mm@kvack.org>; Thu, 06 Sep 2012 05:40:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120821072901.GD1657@suse.de>
References: <1345480594-27032-1-git-send-email-mgorman@suse.de>
	<20120821072901.GD1657@suse.de>
Date: Thu, 6 Sep 2012 08:40:21 -0400
Message-ID: <CA+5PVA7KLmrZGDdaA0zc8nXf3sidwN2VUjWC_k6AjVwHq0dcvg@mail.gmail.com>
Subject: Re: [PATCH 0/5] Memory policy corruption fixes V2
From: Josh Boyer <jwboyer@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Dave Jones <davej@redhat.com>, Christoph Lameter <cl@linux.com>, Ben Hutchings <ben@decadent.org.uk>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Tue, Aug 21, 2012 at 3:29 AM, Mel Gorman <mgorman@suse.de> wrote:
> On Mon, Aug 20, 2012 at 05:36:29PM +0100, Mel Gorman wrote:
>> This is a rebase with some small changes to Kosaki's "mempolicy memory
>> corruption fixlet" series. I had expected that Kosaki would have revised
>> the series by now but it's been waiting a long time.
>>
>> Changelog since V1
>> o Rebase to 3.6-rc2
>> o Editted some of the changelogs
>> o Converted sp->lock to sp->mutex to close a race in shared_policy_replace()
>> o Reworked the refcount imbalance fix slightly
>> o Do not call mpol_put in shmem_alloc_page.
>>
>> I tested this with trinity with CONFIG_DEBUG_SLAB enabled and it passed. I
>> did not test LTP such as Josh reported a problem with or with a database that
>> used shared policies like Andi tested. The series is almost all Kosaki's
>> work of course. If he has a revised series that simply got delayed in
>> posting it should take precedence.
>
> I meant to add Josh to the cc, adding him now.

Thank you.

I see Andi has done some testing and Acked this patchset.  Christoph
appears to have Acked it as well.  Is there anything else needed for
it to get in mainline?  Just want to make sure this doesn't get dropped
because we all forgot about it after KS/Plumbers.

josh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
