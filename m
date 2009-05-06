Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1DD406B0082
	for <linux-mm@kvack.org>; Tue,  5 May 2009 21:52:23 -0400 (EDT)
Message-ID: <4A00ED83.1030700@zytor.com>
Date: Tue, 05 May 2009 18:53:07 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH] x86: 46 bit PAE support
References: <20090505172856.6820db22@cuia.bos.redhat.com>
In-Reply-To: <20090505172856.6820db22@cuia.bos.redhat.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, mingo@redhat.com, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> Testing: booted it on an x86-64 system with 6GB RAM.  Did you really think
> I had access to a system with 64TB of RAM? :)

No, but it would be good if we could test it under Qemu or KVM with an
appropriately set up sparse memory map.

	-hpa

-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
