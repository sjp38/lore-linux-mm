Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3915B8E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 10:00:01 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id w15so5852482qtk.19
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 07:00:01 -0800 (PST)
Received: from smtp-fw-9102.amazon.com (smtp-fw-9102.amazon.com. [207.171.184.29])
        by mx.google.com with ESMTPS id m28si3855563qtf.328.2019.01.16.06.59.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 07:00:00 -0800 (PST)
From: Julian Stecklina <jsteckli@amazon.de>
Subject: Re: [RFC PATCH v7 00/16] Add support for eXclusive Page Frame Ownership
References: <cover.1547153058.git.khalid.aziz@oracle.com>
Date: Wed, 16 Jan 2019 15:56:44 +0100
In-Reply-To: <cover.1547153058.git.khalid.aziz@oracle.com> (Khalid Aziz's
	message of "Thu, 10 Jan 2019 14:09:32 -0700")
Message-ID: <ciirm8o98gzm4z.fsf@u54ee758033e858cfa736.ant.amazon.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Khalid Aziz <khalid.aziz@oracle.com>
Cc: juergh@gmail.com, tycho@tycho.ws, ak@linux.intel.com, torvalds@linux-foundation.org, liran.alon@oracle.com, keescook@google.com, konrad.wilk@oracle.com, deepa.srinivasan@oracle.com, chris.hyser@oracle.com, tyhicks@canonical.com, dwmw@amazon.co.uk, andrew.cooper3@citrix.com, jcm@redhat.com, boris.ostrovsky@oracle.com, kanth.ghatraju@oracle.com, joao.m.martins@oracle.com, jmattson@google.com, pradeep.vincent@oracle.com, john.haxby@oracle.com, tglx@linutronix.de, kirill.shutemov@linux.intel.com, hch@lst.de, steven.sistare@oracle.com, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Khalid Aziz <khalid.aziz@oracle.com> writes:

> I am continuing to build on the work Juerg, Tycho and Julian have done
> on XPFO.

Awesome!

> A rogue process can launch a ret2dir attack only from a CPU that has
> dual mapping for its pages in physmap in its TLB. We can hence defer
> TLB flush on a CPU until a process that would have caused a TLB flush
> is scheduled on that CPU.

Assuming the attacker already has the ability to execute arbitrary code
in userspace, they can just create a second process and thus avoid the
TLB flush. Am I getting this wrong?

Julian
