Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 0B72C6B0035
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 03:51:54 -0500 (EST)
Received: by mail-pd0-f178.google.com with SMTP id y10so7919796pdj.23
        for <linux-mm@kvack.org>; Wed, 18 Dec 2013 00:51:54 -0800 (PST)
Received: from out4-smtp.messagingengine.com (out4-smtp.messagingengine.com. [66.111.4.28])
        by mx.google.com with ESMTPS id 5si13802196pbj.5.2013.12.18.00.51.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Dec 2013 00:51:53 -0800 (PST)
Message-ID: <52B16224.50006@iki.fi>
Date: Wed, 18 Dec 2013 10:51:48 +0200
From: Pekka Enberg <penberg@iki.fi>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 0/7] re-shrink 'struct page' when SLUB is on.
References: <20131213235903.8236C539@viggo.jf.intel.com> <20131216160128.aa1f1eb8039f5eee578cf560@linux-foundation.org> <52AF9EB9.7080606@sr71.net>
In-Reply-To: <52AF9EB9.7080606@sr71.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pravin B Shelar <pshelar@nicira.com>, Christoph Lameter <cl@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Pekka Enberg <penberg@kernel.org>

On 12/17/2013 02:45 AM, Dave Hansen wrote:
> I'll do some testing and see if I can coax out any delta from the
> optimization myself.  Christoph went to a lot of trouble to put this
> together, so I assumed that he had a really good reason, although the
> changelogs don't really mention any.

IIRC it's commit 8a5ec0b ("Lockless (and preemptless) fastpaths for 
slub") that documents the performance gains.

The page alignment patches came later once we discovered that we broke 
the world...

                         Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
