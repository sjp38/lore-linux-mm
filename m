Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6EAC36B03A1
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 16:05:16 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id s23-v6so14262504plq.7
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 13:05:16 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id z32-v6si37916618pgk.507.2018.11.06.13.05.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Nov 2018 13:05:14 -0800 (PST)
Date: Tue, 6 Nov 2018 13:05:11 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v8 1/4] vmalloc: Add __vmalloc_node_try_addr function
Message-Id: <20181106130511.9ebeb5a09aba15dfee2f7f3d@linux-foundation.org>
In-Reply-To: <20181102192520.4522-2-rick.p.edgecombe@intel.com>
References: <20181102192520.4522-1-rick.p.edgecombe@intel.com>
	<20181102192520.4522-2-rick.p.edgecombe@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rick Edgecombe <rick.p.edgecombe@intel.com>
Cc: jeyu@kernel.org, willy@infradead.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, daniel@iogearbox.net, jannh@google.com, keescook@chromium.org, kristen@linux.intel.com, dave.hansen@intel.com, arjan@linux.intel.com

On Fri,  2 Nov 2018 12:25:17 -0700 Rick Edgecombe <rick.p.edgecombe@intel.com> wrote:

> Create __vmalloc_node_try_addr function that tries to allocate at a specific
> address without triggering any lazy purging. In order to support this behavior
> a try_addr argument was plugged into several of the static helpers.

Please explain (in the changelog) why lazy purging is considered to be
a problem.  Preferably with some form of measurements, or at least a
hand-wavy guesstimate of the cost.

> This also changes logic in __get_vm_area_node to be faster in cases where
> allocations fail due to no space, which is a lot more common when trying
> specific addresses.
