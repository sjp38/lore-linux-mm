Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 4E0786B00AD
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 19:41:10 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id q10so332597pdj.35
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 16:41:09 -0700 (PDT)
Date: Wed, 25 Sep 2013 16:40:57 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Results] [RFC PATCH v4 00/40] mm: Memory Power Management
Message-Id: <20130925164057.6bbaf23bdc5057c42b2ab010@linux-foundation.org>
In-Reply-To: <52437128.7030402@linux.vnet.ibm.com>
References: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com>
	<52437128.7030402@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Cc: mgorman@suse.de, dave@sr71.net, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl, gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 26 Sep 2013 04:56:32 +0530 "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com> wrote:

> Experimental Results:
> ====================
> 
> Test setup:
> ----------
> 
> x86 Sandybridge dual-socket quad core HT-enabled machine, with 128GB RAM.
> Memory Region size = 512MB.

Yes, but how much power was saved ;)

Also, the changelogs don't appear to discuss one obvious downside: the
latency incurred in bringing a bank out of one of the low-power states
and back into full operation.  Please do discuss and quantify that to
the best of your knowledge.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
