Return-Path: <linux-kernel-owner@vger.kernel.org>
Date: Mon, 26 Nov 2018 00:21:34 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 5/5] arch: simplify several early memory allocations
Message-ID: <20181126082134.GA10530@infradead.org>
References: <1543182277-8819-1-git-send-email-rppt@linux.ibm.com>
 <1543182277-8819-6-git-send-email-rppt@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1543182277-8819-6-git-send-email-rppt@linux.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@pku.edu.cn>, Greentime Hu <green.hu@gmail.com>, Jonas Bonn <jonas@southpole.se>, Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@suse.com>, Michal Simek <monstr@monstr.eu>, Mark Salter <msalter@redhat.com>, Paul Mackerras <paulus@samba.org>, Rich Felker <dalias@libc.org>, Russell King <linux@armlinux.org.uk>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Stafford Horne <shorne@gmail.com>, Vincent Chen <deanbo422@gmail.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-mm@kvack.org, linux-sh@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, openrisc@lists.librecores.org, sparclinux@vger.kernel.org
List-ID: <linux-mm.kvack.org>

>  static void __init *early_alloc_aligned(unsigned long sz, unsigned long align)
>  {
> -	void *ptr = __va(memblock_phys_alloc(sz, align));
> -	memset(ptr, 0, sz);
> -	return ptr;
> +	return memblock_alloc(sz, align);
>  }

What is the point of keeping this wrapper?

>  static void __init *early_alloc(unsigned long sz)
>  {
> -	void *ptr = __va(memblock_phys_alloc(sz, sz));
> -	memset(ptr, 0, sz);
> -	return ptr;
> +	return memblock_alloc(sz, sz);
>  }

Same here.
