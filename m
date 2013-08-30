Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 1010F6B0033
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 11:27:46 -0400 (EDT)
Message-ID: <5220B9E4.3040306@sr71.net>
Date: Fri, 30 Aug 2013 08:27:32 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [RESEND RFC PATCH v3 00/35] mm: Memory Power Management
References: <20130830131221.4947.99764.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130830131221.4947.99764.stgit@srivatsabhat.in.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl, gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 08/30/2013 06:13 AM, Srivatsa S. Bhat wrote:
> Overview of Memory Power Management and its implications to the Linux MM
> ========================================================================
> 
> Today, we are increasingly seeing computer systems sporting larger and larger
> amounts of RAM, in order to meet workload demands. However, memory consumes a
> significant amount of power, potentially upto more than a third of total system
> power on server systems[4]. So naturally, memory becomes the next big target
> for power management - on embedded systems and smartphones, and all the way
> upto large server systems.

Srivatsa, you're sending a huge patch set to a very long cc list of
people, but you're leading the description with text that most of us
have already read a bunch of times.  Why?

What changed in this patch from the last round?  Where would you like
reviewers to concentrate their time amongst the thousand lines of code?
 What barriers do _you_ see as remaining before this gets merged?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
