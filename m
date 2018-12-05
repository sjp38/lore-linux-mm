Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6EC746B72AC
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 00:30:05 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id m1-v6so14189757plb.13
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 21:30:05 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id 205si19072018pfa.199.2018.12.04.21.30.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 21:30:04 -0800 (PST)
Date: Tue, 4 Dec 2018 21:32:39 -0800
From: Alison Schofield <alison.schofield@intel.com>
Subject: Re: [RFC v2 13/13] keys/mktme: Support CPU Hotplug for MKTME keys
Message-ID: <20181205053239.GC18596@alison-desk.jf.intel.com>
References: <cover.1543903910.git.alison.schofield@intel.com>
 <c14d24b09ee2ae37ea4106726ce8fe2aea31f6c7.1543903910.git.alison.schofield@intel.com>
 <20181204092841.GU11614@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181204092841.GU11614@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: dhowells@redhat.com, tglx@linutronix.de, jmorris@namei.org, mingo@redhat.com, hpa@zytor.com, bp@alien8.de, luto@kernel.org, kirill.shutemov@linux.intel.com, dave.hansen@intel.com, kai.huang@intel.com, jun.nakajima@intel.com, dan.j.williams@intel.com, jarkko.sakkinen@intel.com, keyrings@vger.kernel.org, linux-security-module@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org

On Tue, Dec 04, 2018 at 10:28:41AM +0100, Peter Zijlstra wrote:
> On Mon, Dec 03, 2018 at 11:40:00PM -0800, Alison Schofield wrote:
> > +	for_each_online_cpu(online_cpu)
> > +		if (online_cpu != cpu &&
> > +		    pkgid == topology_physical_package_id(online_cpu)) {
> > +			cpumask_set_cpu(online_cpu, mktme_leadcpus);
> > +			break;
> > +	}
> 
> That's a capital offence right there.
Got it!
