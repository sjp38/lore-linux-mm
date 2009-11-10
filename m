Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9E24F6B004D
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 15:56:01 -0500 (EST)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id nAAKtv2E021484
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 12:55:57 -0800
Received: from pwj10 (pwj10.prod.google.com [10.241.219.74])
	by wpaz17.hot.corp.google.com with ESMTP id nAAKtrqi018501
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 12:55:54 -0800
Received: by pwj10 with SMTP id 10so247840pwj.30
        for <linux-mm@kvack.org>; Tue, 10 Nov 2009 12:55:53 -0800 (PST)
Date: Tue, 10 Nov 2009 12:55:50 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm] mm: slab allocate memory section nodemask for large
 systems
In-Reply-To: <20091110125131.30376c03.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.0911101255020.28728@chino.kir.corp.google.com>
References: <20091022040814.15705.95572.stgit@bob.kio> <20091022041510.15705.5410.stgit@bob.kio> <alpine.DEB.2.00.0910221249030.26631@chino.kir.corp.google.com> <20091027195907.GJ14102@ldl.fc.hp.com> <alpine.DEB.2.00.0910271422090.22335@chino.kir.corp.google.com>
 <20091028083137.GA24140@osiris.boeblingen.de.ibm.com> <alpine.DEB.2.00.0910280159380.7122@chino.kir.corp.google.com> <20091028183905.GF22743@ldl.fc.hp.com> <alpine.DEB.2.00.0910281315370.23279@chino.kir.corp.google.com> <20091102204726.GG5525@ldl.fc.hp.com>
 <20091110125131.30376c03.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alex Chiang <achiang@hp.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Gary Hade <garyhade@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Badari Pulavarty <pbadari@us.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Tue, 10 Nov 2009, Andrew Morton wrote:

> The prerequisite Documentation/ patches are a bit of a mess - some have
> been cherrypicked into Greg's tree I believe and some haven't.  So
> please also send out whatever is needed to bring linux-next up to date.
> 

I'm not aware of any prerequisites for this patchset, Alex's documentation 
changes have already been merged by Linus.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
