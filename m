Return-Path: <linux-kernel-owner@vger.kernel.org>
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.1 \(3445.101.1\))
Subject: Re: [PATCH 03/12] __wr_after_init: generic header
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <20181219213338.26619-4-igor.stoppa@huawei.com>
Date: Fri, 21 Dec 2018 11:38:16 -0800
Content-Transfer-Encoding: 7bit
Message-Id: <8474D7CA-E5FF-40B1-9428-855854CDDB5F@gmail.com>
References: <20181219213338.26619-1-igor.stoppa@huawei.com>
 <20181219213338.26619-4-igor.stoppa@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Igor Stoppa <igor.stoppa@gmail.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Matthew Wilcox <willy@infradead.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Mimi Zohar <zohar@linux.vnet.ibm.com>, igor.stoppa@huawei.com, Kees Cook <keescook@chromium.org>, linux-integrity@vger.kernel.org, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> On Dec 19, 2018, at 1:33 PM, Igor Stoppa <igor.stoppa@gmail.com> wrote:
> 
> +static inline void *wr_memset(void *p, int c, __kernel_size_t len)
> +{
> +	return __wr_op((unsigned long)p, (unsigned long)c, len, WR_MEMSET);
> +}

What do you think about doing something like:

#define __wr          __attribute__((address_space(5)))

And then make all the pointers to write-rarely memory to use this attribute?
It might require more changes to the code, but can prevent bugs.
