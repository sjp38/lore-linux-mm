Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id D50ED6B0003
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 14:20:35 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id w185so33047590qka.9
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 11:20:35 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 19sor11288552qkd.88.2018.11.13.11.20.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 13 Nov 2018 11:20:34 -0800 (PST)
Date: Tue, 13 Nov 2018 19:20:31 +0000
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Subject: Re: [PATCH] l1tf: drop the swap storage limit restriction when
 l1tf=off
Message-ID: <20181113192031.7fq5gkal62ygu6tr@soleen.tm1wkky2jk1uhgkn0ivaxijq1c.bx.internal.cloudapp.net>
References: <20181113184910.26697-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181113184910.26697-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Jiri Kosina <jkosina@suse.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <ak@linux.intel.com>, Borislav Petkov <bp@suse.de>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>

On 18-11-13 19:49:10, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> Swap storage is restricted to max_swapfile_size (~16TB on x86_64)
> whenever the system is deemed affected by L1TF vulnerability. Even
> though the limit is quite high for most deployments it seems to be
> too restrictive for deployments which are willing to live with the
> mitigation disabled.
> 
> We have a customer to deploy 8x 6,4TB PCIe/NVMe SSD swap devices
> which is clearly out of the limit.
> 
> Drop the swap restriction when l1tf=off is specified. It also doesn't
> make much sense to warn about too much memory for the l1tf mitigation
> when it is forcefully disabled by the administrator.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Reviewed-by: Pavel Tatashin <pasha.tatashin@soleen.com>
