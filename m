Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0A1F2440CD7
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 10:01:50 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id j15so3341805wre.15
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 07:01:49 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r17si416054eda.270.2017.11.09.07.01.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Nov 2017 07:01:48 -0800 (PST)
Subject: Re: [PATCH 30/30] x86, kaiser, xen: Dynamically disable KAISER when
 running under Xen PV
References: <20171108194646.907A1942@viggo.jf.intel.com>
 <20171108194742.8CD79E09@viggo.jf.intel.com>
From: Juergen Gross <jgross@suse.com>
Message-ID: <7e70274c-6ad0-9f9c-0ad3-8d3306d8174a@suse.com>
Date: Thu, 9 Nov 2017 16:01:42 +0100
MIME-Version: 1.0
In-Reply-To: <20171108194742.8CD79E09@viggo.jf.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org

On 08/11/17 20:47, Dave Hansen wrote:
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> If you paravirtualize the MMU, you can not use KAISER.  This boils down
> to the fact that KAISER needs to do CR3 writes in places that it is not
> feasible to do real hypercalls.
> 
> If we detect that Xen PV is in use, do not do the KAISER CR3 switches.
> 
> I don't think this too bug of a deal for Xen.  I was under the
> impression that the Xen guest kernel and Xen guest userspace didn't
> share an address space *anyway* so Xen PV is not normally even exposed
> to the kinds of things that KAISER protects against.
> 
> This allows KAISER=y kernels to deployed in environments that also
> require PARAVIRT=y.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>

Acked-by: Juergen Gross <jgross@suse.com>


Juergen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
