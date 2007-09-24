Message-ID: <46F7F25B.6010706@sgi.com>
Date: Mon, 24 Sep 2007 10:22:35 -0700
From: Mike Travis <travis@sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/1] x86: Convert cpuinfo_x86 array to a per_cpu array
 v2
References: <20070920213004.527735000@sgi.com>	<20070920213004.781159000@sgi.com> <20070921154622.c6920dcf.akpm@linux-foundation.org>
In-Reply-To: <20070921154622.c6920dcf.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Thu, 20 Sep 2007 14:30:05 -0700
> travis@sgi.com wrote:
> 
>> cpu_data is currently an array defined using NR_CPUS. This means that
>> we overallocate since we will rarely really use maximum configured cpus.
>> When NR_CPU count is raised to 4096 the size of cpu_data becomes
>> 3,145,728 bytes.
> 
> This has at least three quite obvious and careless compilation errors.
> 
> Please at least compile the code after you've altered it.
> 

Sorry for the build errors, my test build scripts obviously were missing
a critical kernel variant to test build.  I've fixed that omission and
increased the test build matrix significantly:

arch-i386-allmodconfig
arch-i386-allnoconfig
arch-i386-allyesconfig
arch-i386-defconfig
arch-i386-nomodconfig
arch-i386-nosmp
arch-i386-randconfig-1
arch-i386-randconfig-2
arch-i386-randconfig-3
arch-i386-randconfig-4
arch-i386-randconfig-5
arch-i386-smp
arch-x86_64-allmodconfig
arch-x86_64-allnoconfig
arch-x86_64-allyesconfig
arch-x86_64-nomodconfig
arch-x86_64-nosmp
arch-x86_64-randconfig-1
arch-x86_64-randconfig-2
arch-x86_64-randconfig-3
arch-x86_64-randconfig-4
arch-x86_64-randconfig-5
arch-x86_64-smp

A corrected patch follows.

Thanks,
Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
