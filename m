Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 0E9126B0035
	for <linux-mm@kvack.org>; Fri, 25 Jul 2014 11:20:06 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id kq14so6262599pab.40
        for <linux-mm@kvack.org>; Fri, 25 Jul 2014 08:20:06 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id kj10si9514970pbd.63.2014.07.25.08.20.05
        for <linux-mm@kvack.org>;
        Fri, 25 Jul 2014 08:20:06 -0700 (PDT)
Message-ID: <53D27590.2090500@intel.com>
Date: Fri, 25 Jul 2014 08:19:44 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: Background page clearing
References: <000001cfa81a$110d15c0$33274140$@com>
In-Reply-To: <000001cfa81a$110d15c0$33274140$@com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wilco Dijkstra <wdijkstr@arm.com>, linux-mm@kvack.org

On 07/25/2014 08:06 AM, Wilco Dijkstra wrote:
> Is there a reason Linux does not do background page clearing like other OSes to reduce this
> overhead? It would be a good fit for typical mobile workloads (bursts of high activity followed by
> periods of low activity).

If the page is being allocated, it is about to be used and be brought in
to the CPU's cache.  If we zero it close to this use, we only pay to
bring it in to the CPU's cache once.  Or so goes the theory...

I tried a zero-on-free implementation a year or so ago.  It helped some
workloads and hurt others.  The gains were not large enough or
widespread enough to merit pushing it in to the kernel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
