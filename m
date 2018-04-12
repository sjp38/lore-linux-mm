Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id A7C066B0005
	for <linux-mm@kvack.org>; Thu, 12 Apr 2018 13:12:12 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id c11-v6so4255574pll.13
        for <linux-mm@kvack.org>; Thu, 12 Apr 2018 10:12:12 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id a10si2509865pgq.272.2018.04.12.10.12.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Apr 2018 10:12:11 -0700 (PDT)
Date: Thu, 12 Apr 2018 10:12:09 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 198497] New: handle_mm_fault / xen_pmd_val /
 radix_tree_lookup_slot Null pointer
Message-Id: <20180412101209.311c5ee1759449877b233183@linux-foundation.org>
In-Reply-To: <20180209144726.GD16666@bombadil.infradead.org>
References: <20180118135518.639141f0b0ea8bb047ab6306@linux-foundation.org>
	<7ba7635e-249a-9071-75bb-7874506bd2b2@redhat.com>
	<20180119030447.GA26245@bombadil.infradead.org>
	<d38ff996-8294-81a6-075f-d7b2a60aa2f4@rimuhosting.com>
	<20180119132145.GB2897@bombadil.infradead.org>
	<9d2ddba4-3fb3-0fb4-a058-f2cfd1b05538@redhat.com>
	<32ab6fd6-e3c6-9489-8163-aa73861aa71a@rimuhosting.com>
	<20180126194058.GA31600@bombadil.infradead.org>
	<9ff38687-edde-6b4e-4532-9c150f8ea647@rimuhosting.com>
	<20180131105456.GC28275@bombadil.infradead.org>
	<20180209144726.GD16666@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: xen@randonwebstuff.com, Laura Abbott <labbott@redhat.com>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org

On Fri, 9 Feb 2018 06:47:26 -0800 Matthew Wilcox <willy@infradead.org> wrote:

> 
> ping?
> 

There have been a bunch of updates to this issue in bugzilla
(https://bugzilla.kernel.org/show_bug.cgi?id=198497).  Sigh, I don't
know what to do about this - maybe there's some way of getting bugzilla
to echo everything to linux-mm or something.

Anyway, please take a look - we appear to have a bug here.  Perhaps
this bug is sufficiently gnarly for you to prepare a debugging patch
which we can add to the mainline kernel so we get (much) more debugging
info when people hit it?
