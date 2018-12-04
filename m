Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 16CA66B6DFD
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 04:28:48 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id o205so11944367itc.2
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 01:28:48 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id q7si10045104jaj.48.2018.12.04.01.28.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Dec 2018 01:28:47 -0800 (PST)
Date: Tue, 4 Dec 2018 10:28:41 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC v2 13/13] keys/mktme: Support CPU Hotplug for MKTME keys
Message-ID: <20181204092841.GU11614@hirez.programming.kicks-ass.net>
References: <cover.1543903910.git.alison.schofield@intel.com>
 <c14d24b09ee2ae37ea4106726ce8fe2aea31f6c7.1543903910.git.alison.schofield@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c14d24b09ee2ae37ea4106726ce8fe2aea31f6c7.1543903910.git.alison.schofield@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alison Schofield <alison.schofield@intel.com>
Cc: dhowells@redhat.com, tglx@linutronix.de, jmorris@namei.org, mingo@redhat.com, hpa@zytor.com, bp@alien8.de, luto@kernel.org, kirill.shutemov@linux.intel.com, dave.hansen@intel.com, kai.huang@intel.com, jun.nakajima@intel.com, dan.j.williams@intel.com, jarkko.sakkinen@intel.com, keyrings@vger.kernel.org, linux-security-module@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org

On Mon, Dec 03, 2018 at 11:40:00PM -0800, Alison Schofield wrote:
> +	for_each_online_cpu(online_cpu)
> +		if (online_cpu != cpu &&
> +		    pkgid == topology_physical_package_id(online_cpu)) {
> +			cpumask_set_cpu(online_cpu, mktme_leadcpus);
> +			break;
> +	}

That's a capital offence right there.
