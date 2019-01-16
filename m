Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 88E3A8E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 10:05:53 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id q3so5900997qtq.15
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 07:05:53 -0800 (PST)
Received: from smtp-fw-4101.amazon.com (smtp-fw-4101.amazon.com. [72.21.198.25])
        by mx.google.com with ESMTPS id v18si5853047qtp.194.2019.01.16.07.05.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 07:05:52 -0800 (PST)
From: Julian Stecklina <jsteckli@amazon.de>
Subject: Re: [RFC PATCH v7 12/16] xpfo, mm: remove dependency on CONFIG_PAGE_EXTENSION
References: <cover.1547153058.git.khalid.aziz@oracle.com>
	<a9436d3bc7943123bdbaac3f3e2b6bec3153ee05.1547153058.git.khalid.aziz@oracle.com>
Date: Wed, 16 Jan 2019 16:01:05 +0100
In-Reply-To: <a9436d3bc7943123bdbaac3f3e2b6bec3153ee05.1547153058.git.khalid.aziz@oracle.com>
	(Khalid Aziz's message of "Thu, 10 Jan 2019 14:09:44 -0700")
Message-ID: <ciirm8k1j4zlxq.fsf@u54ee758033e858cfa736.ant.amazon.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Khalid Aziz <khalid.aziz@oracle.com>
Cc: juergh@gmail.com, tycho@tycho.ws, ak@linux.intel.com, torvalds@linux-foundation.org, liran.alon@oracle.com, keescook@google.com, konrad.wilk@oracle.com, deepa.srinivasan@oracle.com, chris.hyser@oracle.com, tyhicks@canonical.com, dwmw@amazon.co.uk, andrew.cooper3@citrix.com, jcm@redhat.com, boris.ostrovsky@oracle.com, kanth.ghatraju@oracle.com, joao.m.martins@oracle.com, jmattson@google.com, pradeep.vincent@oracle.com, john.haxby@oracle.com, tglx@linutronix.de, kirill.shutemov@linux.intel.com, hch@lst.de, steven.sistare@oracle.com, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, "Vasileios P . Kemerlis" <vpk@cs.columbia.edu>, Juerg Haefliger <juerg.haefliger@canonical.com>, Tycho Andersen <tycho@docker.com>, Marco Benatto <marco.antonio.780@gmail.com>, David Woodhouse <dwmw2@infradead.org>

Khalid Aziz <khalid.aziz@oracle.com> writes:

> From: Julian Stecklina <jsteckli@amazon.de>
>
> Instead of using the page extension debug feature, encode all
> information, we need for XPFO in struct page. This allows to get rid of
> some checks in the hot paths and there are also no pages anymore that
> are allocated before XPFO is enabled.

I have another patch lying around that turns the XPFO per-page locks
into bit spinlocks and thus get the size of struct page to <= 64 byte
again. In case someone's interested, ping me.

Julian
